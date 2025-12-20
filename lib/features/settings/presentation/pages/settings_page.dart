import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/widgets/nutri_bottom_nav_bar.dart';
import '../../../analysis/presentation/pages/analysis_page.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../meal_planner/presentation/pages/ai_meal_planner_page.dart';
import '../../../my_foods/presentation/pages/my_foods_page.dart';
import '../../../splash/presentation/pages/splash_page.dart';
import '../../../auth/presentation/pages/forgot_password_page.dart';
import '../../../food_entries/domain/entities/food_entry.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/today_entries_cubit.dart';
import 'update_macros_page.dart';
import 'profile_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SettingsCubit(
            getCurrentUserUsecase: sl(),
            logoutUsecase: sl(),
            deleteAccountUsecase: sl(),
          )..loadUser(),
        ),
        BlocProvider(
          create: (_) => TodayEntriesCubit(
            listenTodayEntriesUsecase: sl(),
            updateFoodEntryUsecase: sl(),
            deleteFoodEntryUsecase: sl(),
            addFoodToDietUsecase: sl(),
          )..loadEntries(),
        ),
      ],
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!)),
          );
        }
        if (state.lastAction == SettingsAction.logout) {
          context.read<SettingsCubit>().resetAction();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SplashPage()),
            (route) => false,
          );
        } else if (state.lastAction == SettingsAction.deleteAccount) {
          context.read<SettingsCubit>().resetAction();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SplashPage()),
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        final user = state.user;
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        const Text(
                          'Settings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildProfileCard(user),
                        const SizedBox(height: 24),
                        _buildSectionTitle("Today's entry"),
                        const _TodayEntriesSection(),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Account'),
                        _SettingsTile(
                          label: 'Profile',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProfilePage(user: user),
                              ),
                            ).then((_) => context.read<SettingsCubit>().loadUser());
                          },
                        ),
                        _SettingsTile(
                          label: 'Update Macro Goals',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const UpdateMacrosPage()),
                            );
                          },
                        ),
                        _SettingsTile(
                          label: 'Change Password',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => ForgotPasswordPage()),
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                        _buildSectionTitle('Security'),
                        _SettingsTile(
                          label: state.loggingOut ? 'Logging Out...' : 'Log Out',
                          onTap: state.loggingOut ? null : () => context.read<SettingsCubit>().logout(),
                          highlight: true,
                        ),
                        _SettingsTile(
                          label: state.deletingAccount ? 'Deleting...' : 'Delete Account',
                          onTap: state.deletingAccount ? null : () => context.read<SettingsCubit>().deleteAccount(),
                          highlight: true,
                        ),
                      ],
                    ),
                  ),
                ),
                NutriBottomNavBar(
                  selectedIndex: 4,
                  onAddTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AiMealPlannerPage()),
                    );
                  },
                  onItemSelected: (index) {
                    if (index == 0) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const DashboardPage()),
                      );
                    } else if (index == 1) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const AnalysisPage()),
                      );
                    } else if (index == 3) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const MyFoodsPage()),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(AuthUser user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF1DD06C),
            backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
            child: user.photoUrl == null
                ? Text(
                    _initials(user.name.isNotEmpty ? user.name : user.email),
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name.isEmpty ? 'Anonymous' : user.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 14,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  String _initials(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(' ');
    if (parts.length == 1) {
      final first = parts.first;
      if (first.length == 1) return first.toUpperCase();
      return first.substring(0, 2).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}

class _TodayEntriesSection extends StatelessWidget {
  const _TodayEntriesSection();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodayEntriesCubit, TodayEntriesState>(
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!)),
          );
        }
      },
      builder: (context, state) {
        if (state.status == TodayEntriesStatus.loading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(color: Colors.green),
            ),
          );
        }

        if (state.status == TodayEntriesStatus.failure) {
          return _TodayEntriesCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Unable to fetch today\'s entries',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message ?? 'Something went wrong.',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.read<TodayEntriesCubit>().loadEntries(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state.entries.isEmpty) {
          return _TodayEntriesCard(
            child: Row(
              children: const [
                Icon(Icons.restaurant, color: Colors.white54),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No entries logged today yet.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: state.entries
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TodayEntriesCard(
                    child: _EntryTile(entry: entry),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _TodayEntriesCard extends StatelessWidget {
  const _TodayEntriesCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});

  final FoodEntry entry;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TodayEntriesCubit>();
    final subtitle =
        '${entry.calories} kcal • P: ${entry.protein}g • C: ${entry.carbs}g • F: ${entry.fat}g';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white70),
          onPressed: () => _showEditEntryDialog(context, entry, cubit),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => _confirmDelete(context, entry, cubit),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    FoodEntry entry,
    TodayEntriesCubit cubit,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111111),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Remove entry', style: TextStyle(color: Colors.white)),
          content: Text(
            'Remove ${entry.name}? This will adjust today\'s macros.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await cubit.deleteEntry(entry);
    }
  }

  Future<void> _showEditEntryDialog(
    BuildContext context,
    FoodEntry entry,
    TodayEntriesCubit cubit,
  ) async {
    final nameCtrl = TextEditingController(text: entry.name);
    final caloriesCtrl = TextEditingController(text: entry.calories.toString());
    final proteinCtrl = TextEditingController(text: entry.protein.toString());
    final carbsCtrl = TextEditingController(text: entry.carbs.toString());
    final fatCtrl = TextEditingController(text: entry.fat.toString());

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111111),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Edit entry', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _entryField('Name', nameCtrl),
              const SizedBox(height: 12),
              _entryField(
                'Calories',
                caloriesCtrl,
                suffix: 'kcal',
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
              ),
              const SizedBox(height: 12),
              _entryField(
                'Protein (g)',
                proteinCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
              ),
              const SizedBox(height: 12),
              _entryField(
                'Carbs (g)',
                carbsCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
              ),
              const SizedBox(height: 12),
              _entryField(
                'Fat (g)',
                fatCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final parsed = _parseEntryInputs(
                  context,
                  nameCtrl,
                  caloriesCtrl,
                  proteinCtrl,
                  carbsCtrl,
                  fatCtrl,
                );
                if (parsed == null) return;
                cubit.updateEntry(
                  entry,
                  name: parsed.name,
                  calories: parsed.calories,
                  protein: parsed.protein,
                  carbs: parsed.carbs,
                  fat: parsed.fat,
                );
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != true) {
      return;
    }
  }

  _EntryParsed? _parseEntryInputs(
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

    if (name.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('Enter a food name')));
      return null;
    }
    if ([calories, protein, carbs, fat].contains(null)) {
      messenger.showSnackBar(const SnackBar(content: Text('Enter valid numeric values')));
      return null;
    }

    return _EntryParsed(
      name: name,
      calories: _clampToInt(calories!, 20000),
      protein: _clampToInt(protein!, 2000),
      carbs: _clampToInt(carbs!, 2000),
      fat: _clampToInt(fat!, 2000),
    );
  }

  int _clampToInt(int value, int max) {
    if (value < 0) return 0;
    if (value > max) return max;
    return value;
  }

  Widget _entryField(
    String label,
    TextEditingController controller, {
    String? suffix,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green),
        ),
      ),
    );
  }
}

class _EntryParsed {
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  const _EntryParsed({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.label,
    this.onTap,
    this.highlight = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final background = highlight ? const Color(0xFF1F1F1F) : const Color(0xFF121212);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: onTap == null ? Colors.white38 : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: onTap == null ? Colors.white24 : Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
