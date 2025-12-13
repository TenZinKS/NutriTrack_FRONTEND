import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../pages/login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                'Something went wrong\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return LoginPage();
        }
        return const DashboardPage();
      },
    );
  }
}
