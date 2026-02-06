import 'package:flutter/material.dart';
import 'package:land_measure/core/theme/app_theme.dart';
import 'package:land_measure/features/measurement/presentation/widgets/feature_tile.dart';

import '../presentation.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.crop_square),
        title: Text('Land Measure'),
      ),
      body: Padding(
        padding: .all(8.0),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/welcome_image.png'),
            Text.rich(
              style: Theme.of(context).textTheme.headlineMedium,
              TextSpan(
                children: [
                  TextSpan(text: 'Measure Land '),
                  TextSpan(
                    text: 'Anywhere',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: AppColors.neonGreen,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Precision GPS measurement tool for professionals. Works 100% offline in temote areas.',
            ),
            FeatureTile(
              leading: Icons.gps_fixed,
              title: 'GPS Accuracy',
              subtitle: 'High-precision tracking',
            ),
            FeatureTile(
              leading: Icons.cloud_off,
              title: '100% Offline',
              subtitle: 'No signal needed',
            ),
            FeatureTile(
              leading: Icons.square_foot_sharp,
              title: 'Instant Area',
              subtitle: 'measure Area instantly',
            ),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => MeasurementScreen()),
                );
              },
              iconAlignment: IconAlignment.end,
              icon: Icon(Icons.arrow_forward),
              label: Text('Start measuring'),
            ),
          ],
        ),
      ),
    );
  }
}
