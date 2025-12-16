import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../dashboard/domain/usecases/watch_onboarding_status_usecase.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../onboarding/presentation/pages/welcome_goals_page.dart';
import '../pages/login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        if (snapshot.hasError) {
          return _buildError(snapshot.error);
        }

        final user = snapshot.data;
        if (user == null) {
          return LoginPage();
        }

        return StreamBuilder<bool>(
          stream: sl<WatchOnboardingStatusUsecase>()(),
          builder: (context, onboardingSnapshot) {
            if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
              return _buildLoading();
            }

            if (onboardingSnapshot.hasError) {
              return _buildError(onboardingSnapshot.error);
            }

            final completed = onboardingSnapshot.data ?? false;
            if (!completed) {
              return const WelcomeGoalsPage();
            }

            return const DashboardPage();
          },
        );
      },
    );
  }

  Widget _buildLoading() {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      ),
    );
  }

  Widget _buildError(Object? error) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'Something went wrong\n${error ?? 'Unknown error'}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
