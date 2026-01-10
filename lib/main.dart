import 'package:flutter/material.dart';
import 'package:land_measure/theme/app_theme.dart';

void main() {
  runApp(const LandMeasure());
}

class LandMeasure extends StatelessWidget {
  const LandMeasure({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Land Measure',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const Center(child: Text("This is a land Measure App")),
    );
  }
}

