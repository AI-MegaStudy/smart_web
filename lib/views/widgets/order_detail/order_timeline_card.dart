import 'package:flutter/material.dart';

import '../common/app_vertical_progress.dart';

class OrderTimelineCard extends StatelessWidget {
  const OrderTimelineCard({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  final List<String> steps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('배송 상태 타임라인', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 28),
            AppVerticalProgress(
              currentStep: currentStep,
              steps: steps,
            ),
          ],
        ),
      ),
    );
  }
}
