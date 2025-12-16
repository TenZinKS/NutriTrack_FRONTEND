import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../domain/entities/custom_food.dart';
import '../cubit/custom_food_cubit.dart';

class AddCustomFoodPage extends StatefulWidget {
  const AddCustomFoodPage({super.key});

  @override
  State<AddCustomFoodPage> createState() => _AddCustomFoodPageState();
}

class _AddCustomFoodPageState extends State<AddCustomFoodPage> {
  final _nameCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _caloriesCtrl.dispose();
    _proteinCtrl.dispose();
    _carbsCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomFoodCubit(
        saveCustomFoodUsecase: sl(),
        addFoodToDietUsecase: sl(),
      ),
      child: BlocConsumer<CustomFoodCubit, CustomFoodState>(
        listener: (context, state) {
          if (state.lastAction == CustomFoodAction.saveToFoods) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added to My Foods')),
            );
            Navigator.of(context).pop(true);
          } else if (state.lastAction == CustomFoodAction.addToDiet) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added to diet and saved to My Foods')),
            );
            Navigator.of(context).pop(true);
          } else if (state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message!)),
            );
          }
        },
        builder: (context, state) {
          final savingFoods = state.savingFoods;
          final savingDiet = state.savingDiet;
          return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 32),
                    _buildLabel('Food Name'),
                    _buildInput(_nameCtrl, hint: 'e.g. Avocado Toast'),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Calories'),
                              _buildInput(_caloriesCtrl, keyboard: TextInputType.number),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Protein (g)'),
                              _buildInput(_proteinCtrl, keyboard: TextInputType.number),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Carbs (g)'),
                              _buildInput(_carbsCtrl, keyboard: TextInputType.number),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Fat (g)'),
                              _buildInput(_fatCtrl, keyboard: TextInputType.number),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _buildActionButton(
                      label: savingDiet ? 'Adding…' : 'Add to Diet',
                      onPressed: savingDiet ? null : () => _onAddToDiet(context),
                      color: const Color(0xFF1DD06C),
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      label: savingFoods ? 'Saving…' : 'Add to My Foods',
                      onPressed: savingFoods ? null : () => _onSaveToFoods(context),
                      color: const Color(0xFF20A4F3),
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
          onTap: () => Navigator.of(context).pop(),
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
          'Add Custom Food',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 15),
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
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1DD06C), width: 2),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed == null ? Colors.white12 : color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: onPressed == null ? Colors.white54 : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _onSaveToFoods(BuildContext context) {
    final food = _buildFood(context);
    if (food == null) return;
    context.read<CustomFoodCubit>().saveToFoods(food);
  }

  void _onAddToDiet(BuildContext context) {
    final food = _buildFood(context);
    if (food == null) return;
    context.read<CustomFoodCubit>().addToDiet(food);
  }

  CustomFood? _buildFood(BuildContext context) {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a food name')),
      );
      return null;
    }

    return CustomFood(
      id: '',
      name: name,
      calories: _tryParse(_caloriesCtrl.text),
      protein: _tryParse(_proteinCtrl.text),
      carbs: _tryParse(_carbsCtrl.text),
      fat: _tryParse(_fatCtrl.text),
      isFavorite: false,
    );
  }

  int _tryParse(String value) {
    return int.tryParse(value.trim()) ?? 0;
  }
}
