import 'package:flutter/material.dart';
import 'package:land_measure/core/theme/app_theme.dart';

class MeasurementScreen extends StatelessWidget {
  const MeasurementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: CircleAvatar(
          backgroundColor: AppColors.backgroundDark,
          child: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
        ),
        title: Container(
          padding: .symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Icon(
                Icons.satellite_alt,
                color: AppColors.neonGreen,
              ),
              Text('GPS High (+2)'),
            ],
          ),
        ),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.settings))],
      ),
    );
  }
}
