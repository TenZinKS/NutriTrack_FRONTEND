import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/di/injector.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initDependencies();

  runApp(const NutriTrackApp());
}

class NutriTrackApp extends StatelessWidget {
  const NutriTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
