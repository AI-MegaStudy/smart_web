import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';

class AppVerticalProgress extends StatelessWidget {
  const AppVerticalProgress({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  final List<String> steps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i <= currentStep ? AppColors.primary : const Color(0xFFE7E1D6),
                    ),
                    child: Icon(
                      i <= currentStep ? Icons.check_rounded : Icons.circle,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  if (i != steps.length - 1)
                    Container(
                      width: 4,
                      height: 50,
                      color: i < currentStep ? const Color(0xFFB8D7B6) : const Color(0xFFE7E1D6),
                    ),
                ],
              ),
              const SizedBox(width: 18),
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(steps[i], style: theme.textTheme.titleLarge),
              ),
            ],
          ),
      ],
    );
  }
}
