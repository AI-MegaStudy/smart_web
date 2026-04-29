import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';

class InfoPlaceholderPage extends StatelessWidget {
  const InfoPlaceholderPage({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(icon, size: 56, color: AppColors.primary),
            const SizedBox(height: 20),
            Text(title, style: theme.textTheme.displayLarge?.copyWith(fontSize: 36)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
