import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../dashboard/domain/usecases/complete_onboarding_usecase.dart';
import '../../../dashboard/domain/usecases/get_current_user_macros_usecase.dart';
import '../../../dashboard/domain/usecases/update_user_macros_usecase.dart';
import '../../domain/entities/nutrition_targets.dart';
import '../../domain/usecases/calculate_nutrition_targets_usecase.dart';
import '../cubit/welcome_goals_cubit.dart';

class WelcomeGoalsPage extends StatefulWidget {
  const WelcomeGoalsPage({super.key});

  @override
  State<WelcomeGoalsPage> createState() => _WelcomeGoalsPageState();
}

class _WelcomeGoalsPageState extends State<WelcomeGoalsPage> {
  final _heightCtrl = TextEditingController();
  final _currentWeightCtrl = TextEditingController();
  final _targetWeightCtrl = TextEditingController();
  NutritionGender? _selectedGender;
  NutritionActivityLevel? _activityLevel;
  bool _synced = false;

  @override
  void dispose() {
    _heightCtrl.dispose();
    _currentWeightCtrl.dispose();
    _targetWeightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WelcomeGoalsCubit(
        getCurrentUserMacrosUsecase: sl<GetCurrentUserMacrosUsecase>(),
        updateUserMacrosUsecase: sl<UpdateUserMacrosUsecase>(),
        completeOnboardingUsecase: sl<CompleteOnboardingUsecase>(),
        calculateNutritionTargetsUsecase:
            sl<CalculateNutritionTargetsUsecase>(),
      )..loadGoals(),
      child: BlocListener<WelcomeGoalsCubit, WelcomeGoalsState>(
        listener: (context, state) {
          if (!_synced && state.status == WelcomeGoalsStatus.ready) {
            _synced = true;
          }

          if (state.status == WelcomeGoalsStatus.failure &&
              state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message!)),
            );
          } else if (state.status == WelcomeGoalsStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Goals saved successfully')),
            );
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop(true);
            }
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: BlocBuilder<WelcomeGoalsCubit, WelcomeGoalsState>(
              builder: (context, state) {
                if (state.status == WelcomeGoalsStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  );
                }

                if (state.status == WelcomeGoalsStatus.failure &&
                    !_synced) {
                  return _errorView(context);
                }

                final isSubmitting =
                    state.status == WelcomeGoalsStatus.submitting;

                final canPop = Navigator.of(context).canPop();

                return SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (canPop)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
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
                        ),
                      const Text(
                        'Welcome!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Set daily goals so we can personalize your dashboard, '
                        'analysis, and meal plans.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Tell us about yourself',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _genderSelector(),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _infoField(
                              label: 'Height',
                              controller: _heightCtrl,
                              suffix: 'cm',
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _infoField(
                              label: 'Current Weight',
                              controller: _currentWeightCtrl,
                              suffix: 'kg',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _infoField(
                        label: 'Target Weight',
                        controller: _targetWeightCtrl,
                        suffix: 'kg',
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'How active are you?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _activitySelector(),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              isSubmitting ? null : () => _useRecommended(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Calculate For Me',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _errorView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 12),
          const Text(
            'We could not load your goals.',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () =>
                context.read<WelcomeGoalsCubit>().loadGoals(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _infoField({
    required String label,
    required TextEditingController controller,
    required String suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF101010),
            hintText: '0',
            hintStyle: const TextStyle(color: Colors.white24),
            suffixText: suffix,
            suffixStyle: const TextStyle(color: Colors.white54),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white24),
              borderRadius: BorderRadius.circular(16),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.green),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _genderSelector() {
    return Row(
      children: [
        Expanded(child: _genderChip('Male', NutritionGender.male)),
        const SizedBox(width: 12),
        Expanded(child: _genderChip('Female', NutritionGender.female)),
      ],
    );
  }

  Widget _genderChip(String label, NutritionGender gender) {
    final selected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: selected ? Colors.green : const Color(0xFF101010),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.green : Colors.white24,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _activitySelector() {
    return Column(
      children: [
        _activityTile(
          title: 'Sedentary',
          description: 'Little or no exercise',
          level: NutritionActivityLevel.sedentary,
        ),
        const SizedBox(height: 12),
        _activityTile(
          title: 'Lightly Active',
          description: '1-3 workouts per week',
          level: NutritionActivityLevel.lightlyActive,
        ),
        const SizedBox(height: 12),
        _activityTile(
          title: 'Moderately Active',
          description: '3-5 workouts per week',
          level: NutritionActivityLevel.moderatelyActive,
        ),
        const SizedBox(height: 12),
        _activityTile(
          title: 'Very Active',
          description: '6+ workouts or physical job',
          level: NutritionActivityLevel.veryActive,
        ),
      ],
    );
  }

  Widget _activityTile({
    required String title,
    required String description,
    required NutritionActivityLevel level,
  }) {
    final selected = _activityLevel == level;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activityLevel = level;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1DD06C).withOpacity(0.15) : const Color(0xFF101010),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? Colors.green : Colors.white24,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? Colors.green : Colors.white38,
                  width: 2,
                ),
              ),
              child: selected
                  ? Container(
                      margin: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _useRecommended(BuildContext context) async {
    final gender = _selectedGender;
    final height = double.tryParse(_heightCtrl.text);
    final currentWeight = double.tryParse(_currentWeightCtrl.text);
    final targetWeight = double.tryParse(_targetWeightCtrl.text);
    final activityLevel = _activityLevel;

    if (gender == null) {
      _showMessage(context, 'Please select a gender.');
      return;
    }
    if (height == null || height <= 0) {
      _showMessage(context, 'Enter a valid height in centimeters.');
      return;
    }
    if (currentWeight == null || currentWeight <= 0) {
      _showMessage(context, 'Enter a valid current weight.');
      return;
    }
    if (targetWeight == null || targetWeight <= 0) {
      _showMessage(context, 'Enter a valid target weight.');
      return;
    }
    if (activityLevel == null) {
      _showMessage(context, 'Select how active you are.');
      return;
    }

    FocusScope.of(context).unfocus();

    final cubit = context.read<WelcomeGoalsCubit>();
    final targets = cubit.applyCalculatedTargets(
      gender: gender,
      heightCm: height,
      currentWeightKg: currentWeight,
      targetWeightKg: targetWeight,
      activityLevel: activityLevel,
    );
    final confirmed = await _showRecommendedDialog(context, targets);
    if (confirmed == true) {
      await cubit.saveGoals();
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<bool?> _showRecommendedDialog(
    BuildContext context,
    NutritionTargets targets,
  ) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101010),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Recommended Macros',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dialogRow('Calories', '${targets.calories} kcal'),
              _dialogRow('Carbs', '${targets.carbsGrams} g'),
              _dialogRow('Protein', '${targets.proteinGrams} g'),
              _dialogRow('Fat', '${targets.fatGrams} g'),
              const SizedBox(height: 12),
              const Text(
                'Tap OK to apply and continue to your dashboard.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _dialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
