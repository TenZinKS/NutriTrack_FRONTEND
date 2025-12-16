import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../dashboard/domain/usecases/get_current_user_macros_usecase.dart';
import '../../../dashboard/domain/usecases/update_user_macros_usecase.dart';
import '../cubit/update_macros_cubit.dart';

class UpdateMacrosPage extends StatefulWidget {
  const UpdateMacrosPage({super.key});

  @override
  State<UpdateMacrosPage> createState() => _UpdateMacrosPageState();
}

class _UpdateMacrosPageState extends State<UpdateMacrosPage> {
  final _caloriesCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _waterCtrl = TextEditingController();
  bool _synced = false;

  @override
  void dispose() {
    _caloriesCtrl.dispose();
    _carbsCtrl.dispose();
    _proteinCtrl.dispose();
    _fatCtrl.dispose();
    _waterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UpdateMacrosCubit(
        getCurrentUserMacrosUsecase: sl<GetCurrentUserMacrosUsecase>(),
        updateUserMacrosUsecase: sl<UpdateUserMacrosUsecase>(),
      )..loadMacros(),
      child: BlocListener<UpdateMacrosCubit, UpdateMacrosState>(
        listener: (context, state) {
          if (!_synced && state.status == UpdateMacrosStatus.ready) {
            _setIfChanged(_caloriesCtrl, state.caloriesGoal);
            _setIfChanged(_carbsCtrl, state.carbsGoal);
            _setIfChanged(_proteinCtrl, state.proteinGoal);
            _setIfChanged(_fatCtrl, state.fatGoal);
            _setIfChanged(_waterCtrl, state.waterGoal);
            _synced = true;
          }

          if (state.status == UpdateMacrosStatus.failure && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message!)),
            );
          }

          if (state.status == UpdateMacrosStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Macros updated successfully')),
            );
            Navigator.of(context).maybePop();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Update Macro Goals',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          body: SafeArea(
            child: BlocBuilder<UpdateMacrosCubit, UpdateMacrosState>(
              builder: (context, state) {
                if (state.status == UpdateMacrosStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  );
                }

                if (state.status == UpdateMacrosStatus.failure && !_synced) {
                  return _errorView(context);
                }

                final isSubmitting = state.status == UpdateMacrosStatus.submitting;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enter the macro goals you would like to follow. These will immediately update your dashboard and planning tools.',
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                      const SizedBox(height: 28),
                      _goalField(
                        label: 'Calories Goal',
                        controller: _caloriesCtrl,
                        suffix: 'kcal',
                        onChanged: context.read<UpdateMacrosCubit>().updateCalories,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _goalField(
                              label: 'Carbs Goal',
                              controller: _carbsCtrl,
                              suffix: 'g',
                              onChanged: context.read<UpdateMacrosCubit>().updateCarbs,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _goalField(
                              label: 'Protein Goal',
                              controller: _proteinCtrl,
                              suffix: 'g',
                              onChanged: context.read<UpdateMacrosCubit>().updateProtein,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _goalField(
                              label: 'Fat Goal',
                              controller: _fatCtrl,
                              suffix: 'g',
                              onChanged: context.read<UpdateMacrosCubit>().updateFat,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _goalField(
                              label: 'Water Goal',
                              controller: _waterCtrl,
                              suffix: 'ml',
                              onChanged: context.read<UpdateMacrosCubit>().updateWater,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : () => context.read<UpdateMacrosCubit>().save(),
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
                                  'Save Goals',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
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
            'We could not load your macros.',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => context.read<UpdateMacrosCubit>().loadMacros(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _goalField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
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
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF101010),
            hintText: '0',
            hintStyle: const TextStyle(color: Colors.white24),
            suffixText: suffix,
            suffixStyle: const TextStyle(color: Colors.white54),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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

  void _setIfChanged(TextEditingController controller, int value) {
    final text = value.toString();
    if (controller.text != text) {
      controller.text = text;
    }
  }
}
