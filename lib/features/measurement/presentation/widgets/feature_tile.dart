import 'package:flutter/material.dart';
import 'package:land_measure/core/theme/app_theme.dart';

class FeatureTile extends StatelessWidget {
  final IconData leading;
  final String title;
  final String subtitle;

  const FeatureTile({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: .circular(10),
        side: BorderSide(color: AppColors.textSecondary, width: 1),
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withAlpha(100),
          borderRadius: .circular(10),
        ),
        child: Icon(
          leading,
          color: AppColors.primaryGreen,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
