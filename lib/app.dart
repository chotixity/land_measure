import 'package:flutter/material.dart';
import 'package:land_measure/core/theme/app_theme.dart';
import 'package:land_measure/features/measurement/presentation/presentation.dart';

class LandMeasureApp extends StatelessWidget {
  const LandMeasureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Land Measure',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}
