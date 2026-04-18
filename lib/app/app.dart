import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../features/lessons/screens/splash_screen.dart';

class GraamaShaaleApp extends StatelessWidget {
  const GraamaShaaleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GraamaShaale',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}