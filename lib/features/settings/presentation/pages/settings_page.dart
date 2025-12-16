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
import 'update_macros_page.dart';
import '../cubit/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit(
        getCurrentUserUsecase: sl(),
        logoutUsecase: sl(),
        deleteAccountUsecase: sl(),
      )..loadUser(),
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
                        _buildSectionTitle('Account'),
                        _SettingsTile(
                          label: 'Profile',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profile coming soon')),
                            );
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
      return first.isEmpty ? '?' : first[0].toUpperCase();
    }
    final first = parts[0].isNotEmpty ? parts[0][0] : '';
    final second = parts[1].isNotEmpty ? parts[1][0] : '';
    final combined = (first + second).trim();
    return combined.isEmpty ? '?' : combined.toUpperCase();
  }
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
