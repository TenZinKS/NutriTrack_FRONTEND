import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../domain/entities/custom_food.dart';
import '../cubit/food_detail_cubit.dart';

class FoodDetailPage extends StatelessWidget {
  const FoodDetailPage({super.key, required this.food});

  final CustomFood food;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FoodDetailCubit(
        food: food,
        updateCustomFoodUsecase: sl(),
        toggleFavoriteFoodUsecase: sl(),
        deleteCustomFoodUsecase: sl(),
        addFoodToDietUsecase: sl(),
      ),
      child: const _FoodDetailView(),
    );
  }
}

class _FoodDetailView extends StatelessWidget {
  const _FoodDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FoodDetailCubit, FoodDetailState>(
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message!)));
        }
        if (state.deleted) {
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, state) {
        final food = state.food;
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            title: Text(food.name, style: const TextStyle(color: Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              TextButton(
                onPressed: state.isProcessing
                    ? null
                    : () => _showEditDialog(context, food),
                child: const Text('Edit'),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _macroTile('Calories', '${food.calories} kcal'),
              _macroTile('Protein', '${food.protein} g'),
              _macroTile('Carbs', '${food.carbs} g'),
              _macroTile('Fat', '${food.fat} g'),
              const Spacer(),
              _actionButtons(context, state),
            ],
          ),
            ),
          ),
        );
      },
    );
  }

  Widget _macroTile(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }

  Widget _actionButtons(BuildContext context, FoodDetailState state) {
    final cubit = context.read<FoodDetailCubit>();
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: state.isProcessing ? null : () => cubit.addToDiet(),
            icon: const Icon(Icons.local_dining),
            label: const Text('Add to diet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: state.isProcessing ? null : () => cubit.toggleFavorite(),
            icon: Icon(
              state.food.isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
            label: Text(state.food.isFavorite
                ? 'Marked as favorite'
                : 'Mark as favorite'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: state.isProcessing
                ? null
                : () => _confirmDelete(context, cubit),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.redAccent),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Delete food',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    FoodDetailCubit cubit,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111111),
          title: const Text('Delete food', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Are you sure you want to delete this food?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await cubit.deleteFood();
    }
  }

  Future<void> _showEditDialog(BuildContext context, CustomFood food) async {
    final cubit = context.read<FoodDetailCubit>();
    final nameCtrl = TextEditingController(text: food.name);
    final caloriesCtrl = TextEditingController(text: food.calories.toString());
    final proteinCtrl = TextEditingController(text: food.protein.toString());
    final carbsCtrl = TextEditingController(text: food.carbs.toString());
    final fatCtrl = TextEditingController(text: food.fat.toString());

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF121212),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Edit Food', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _editField(nameCtrl, 'Name', TextInputType.text),
                const SizedBox(height: 12),
                _editField(caloriesCtrl, 'Calories (kcal)',
                    const TextInputType.numberWithOptions(decimal: false)),
                const SizedBox(height: 12),
                _editField(proteinCtrl, 'Protein (g)',
                    const TextInputType.numberWithOptions(decimal: false)),
                const SizedBox(height: 12),
                _editField(carbsCtrl, 'Carbs (g)',
                    const TextInputType.numberWithOptions(decimal: false)),
                const SizedBox(height: 12),
                _editField(fatCtrl, 'Fat (g)',
                    const TextInputType.numberWithOptions(decimal: false)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final parsed = _parseEditInputs(
                  context,
                  nameCtrl,
                  caloriesCtrl,
                  proteinCtrl,
                  carbsCtrl,
                  fatCtrl,
                );
                if (parsed == null) return;
                cubit.updateFood(
                  name: parsed.name,
                  calories: parsed.calories,
                  protein: parsed.protein,
                  carbs: parsed.carbs,
                  fat: parsed.fat,
                );
                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _editField(
    TextEditingController controller,
    String label,
    TextInputType type,
  ) {
    return TextField(
      controller: controller,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.green),
        ),
      ),
    );
  }

  _ParsedFood? _parseEditInputs(
    BuildContext context,
    TextEditingController nameCtrl,
    TextEditingController caloriesCtrl,
    TextEditingController proteinCtrl,
    TextEditingController carbsCtrl,
    TextEditingController fatCtrl,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    final name = nameCtrl.text.trim();
    final calories = int.tryParse(caloriesCtrl.text);
    final protein = int.tryParse(proteinCtrl.text);
    final carbs = int.tryParse(carbsCtrl.text);
    final fat = int.tryParse(fatCtrl.text);

    if (name.isEmpty ||
        calories == null ||
        protein == null ||
        carbs == null ||
        fat == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Enter valid values for all fields')),
      );
      return null;
    }

    return _ParsedFood(
      name: name,
      calories: calories.clamp(0, 20000),
      protein: protein.clamp(0, 2000),
      carbs: carbs.clamp(0, 2000),
      fat: fat.clamp(0, 2000),
    );
  }
}

class _ParsedFood {
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  const _ParsedFood({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}
