import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../domain/entities/meal_plan.dart';
import '../../domain/entities/meal_plan_request.dart';
import '../bloc/meal_planner_bloc.dart';
import '../bloc/meal_planner_event.dart';
import '../bloc/meal_planner_state.dart';
import '../../../my_foods/presentation/pages/add_custom_food_page.dart';

class AiMealPlannerPage extends StatefulWidget {
  const AiMealPlannerPage({super.key});

  @override
  State<AiMealPlannerPage> createState() => _AiMealPlannerPageState();
}

class _AiMealPlannerPageState extends State<AiMealPlannerPage> {
  final _requirementCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();

  final _mealTypes = const ['Breakfast', 'Lunch', 'Dinner','Snack'];
  int _selectedMealIndex = 0;

  @override
  void dispose() {
    _requirementCtrl.dispose();
    _caloriesCtrl.dispose();
    _proteinCtrl.dispose();
    _carbsCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MealPlannerBloc(
        generateMealPlanUsecase: sl(),
        saveMealUsecase: sl(),
      ),
      child: BlocConsumer<MealPlannerBloc, MealPlannerState>(
        listener: (context, state) {
          if (state.status == MealPlannerStatus.failure && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message!)),
            );
          } else if (state.status == MealPlannerStatus.saved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Meal added to My Foods')),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.status == MealPlannerStatus.loading;
          final isSaving = state.status == MealPlannerStatus.saving;
          final hasMeals = state.hasMeals;
          final selectedMeal = state.selectedMeal;

          return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(context),
                            const SizedBox(height: 32),
                            _buildMealTypeSelector(),
                            const SizedBox(height: 24),
                            _buildLabel('Enter your requirements'),
                            _buildInput(_requirementCtrl, hint: 'e.g. high protein wrap'),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Enter Calories'),
                                      _buildInput(_caloriesCtrl, keyboard: TextInputType.number),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Enter Protein'),
                                      _buildInput(_proteinCtrl, keyboard: TextInputType.number),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Enter Carbs'),
                                      _buildInput(_carbsCtrl, keyboard: TextInputType.number),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Enter Fat'),
                                      _buildInput(_fatCtrl, keyboard: TextInputType.number),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildSuggestionsSection(context, state, isLoading),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPrimaryButton(
                      label: isLoading && !hasMeals ? 'Creating...' : 'Create Meals',
                      activeColor: const Color(0xFF1DD06C),
                      onPressed: isLoading
                          ? null
                          : () {
                              final requirements = _requirementCtrl.text.trim();
                              if (requirements.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please describe what you want to eat or any dietary needs.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              final request = MealPlanRequest(
                                mealType: _mealTypes[_selectedMealIndex],
                                requirements: requirements,
                                calories: _parseInt(_caloriesCtrl.text),
                                protein: _parseInt(_proteinCtrl.text),
                                carbs: _parseInt(_carbsCtrl.text),
                                fat: _parseInt(_fatCtrl.text),
                              );
                              context.read<MealPlannerBloc>().add(
                                    GenerateMealPlanEvent(request),
                                  );
                            },
                    ),
                    if (hasMeals) ...[
                      const SizedBox(height: 12),
                      _buildSecondaryButton(
                        label: 'Regenerate List',
                        onPressed: isLoading
                            ? null
                            : () => context
                                .read<MealPlannerBloc>()
                                .add(RegenerateMealPlanEvent()),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildPrimaryButton(
                      label: isSaving ? 'Saving...' : 'Add Selected to My Foods',
                      activeColor: const Color(0xFF00C9C9),
                      activeTextColor: Colors.white,
                      onPressed: (selectedMeal == null || isSaving)
                          ? null
                          : () {
                              context.read<MealPlannerBloc>().add(SaveMealEvent(selectedMeal));
                            },
                    ),
                    const SizedBox(height: 12),
                    _buildPrimaryButton(
                      label: 'Add Custom Food',
                      activeColor: const Color(0xFFFF8A1D),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AddCustomFoodPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const SizedBox(width: 16),
        const Text(
          'AI Meal Planner',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildMealTypeSelector() {
    return Row(
      children: List.generate(_mealTypes.length, (index) {
        final isSelected = _selectedMealIndex == index;
        const greenColor = Color(0xFF1DD06C);
        const orangeColor = Color(0xFFFF8A1D);
        final backgroundColor = isSelected ? greenColor : orangeColor;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedMealIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: backgroundColor),
                ),
                child: Text(
                  _mealTypes[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller, {
    String? hint,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF111111),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF1DD06C), width: 2),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback? onPressed,
    required Color activeColor,
    Color activeTextColor = Colors.black,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed == null ? Colors.white12 : activeColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: onPressed == null ? Colors.white54 : activeTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: onPressed == null ? Colors.white24 : const Color(0xFF1DD06C),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: onPressed == null ? Colors.white54 : Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsSection(
    BuildContext context,
    MealPlannerState state,
    bool isLoading,
  ) {
    if (state.hasMeals) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Meal suggestions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(
                minHeight: 4,
                color: Color(0xFF1DD06C),
                backgroundColor: Colors.white12,
              ),
            ),
          ...List.generate(state.meals.length, (index) {
            final meal = state.meals[index];
            final isSelected = index == state.selectedIndex;
            return _mealOptionCard(context, meal, isSelected, index);
          }),
        ],
      );
    }

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return _buildIdlePlaceholder();
  }

  Widget _buildIdlePlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: const Text(
        'Tell us what you are craving plus your macros, then tap "Create Meals" to see AI suggestions.',
        style: TextStyle(color: Colors.white60, fontSize: 14),
      ),
    );
  }

  Widget _mealOptionCard(
    BuildContext context,
    MealPlan meal,
    bool isSelected,
    int index,
  ) {
    return GestureDetector(
      onTap: () =>
          context.read<MealPlannerBloc>().add(SelectMealOptionEvent(index)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFF1DD06C) : Colors.white12,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.title.isEmpty ? meal.mealType : meal.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meal.mealType,
                        style: const TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected ? const Color(0xFF1DD06C) : Colors.white38,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (meal.suggestion.isNotEmpty)
              Text(
                meal.suggestion,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _chip('Calories', meal.calories),
                _chip('Protein', meal.protein, suffix: 'g'),
                _chip('Carbs', meal.carbs, suffix: 'g'),
                _chip('Fat', meal.fat, suffix: 'g'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, int value, {String suffix = 'kcal'}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        '$label: $value$suffix',
        style: const TextStyle(color: Colors.white70, fontSize: 13),
      ),
    );
  }

  int? _parseInt(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

}
