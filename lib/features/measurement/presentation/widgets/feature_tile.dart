import 'package:flutter/material.dart';

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
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: .circular(10),
        ),
        child: Icon(leading),
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
