import 'package:flutter/material.dart';

class FlowStatusBadge extends StatelessWidget {
  const FlowStatusBadge({
    super.key,
    required this.stepLabel,
    required this.statusLabel,
    this.icon = Icons.route_outlined,
  });

  final String stepLabel;
  final String statusLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 560;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.72),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.18),
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 10 : 14,
            vertical: isCompact ? 7 : 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: isCompact ? 16 : 18, color: colorScheme.primary),
              SizedBox(width: isCompact ? 5 : 7),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCompact)
                    Text(
                      stepLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  Text(
                    isCompact ? statusLabel : statusLabel,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w900,
                      height: isCompact ? 1 : 1.25,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
