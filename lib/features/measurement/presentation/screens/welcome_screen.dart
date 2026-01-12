import 'package:flutter/material.dart';
import 'package:land_measure/features/measurement/presentation/widgets/feature_tile.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        FeatureTile(
          leading: Icons.gps_fixed,
          title: 'GPS Accuracy',
          subtitle: 'High-precision tracking',
        ),
      ],
    );
  }
}
