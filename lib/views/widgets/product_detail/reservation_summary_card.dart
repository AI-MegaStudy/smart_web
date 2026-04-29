import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../common/app_count_button.dart';
import '../common/fruit_tile.dart';

class ReservationSummaryCard extends StatelessWidget {
  const ReservationSummaryCard({
    super.key,
    required this.packageCount,
    required this.unitKg,
    required this.totalAmount,
    required this.onChangePackageCount,
  });

  final int packageCount;
  final int unitKg;
  final int totalAmount;
  final ValueChanged<int> onChangePackageCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Row(
          children: [
            Expanded(
              flex: 9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('예약 수량', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      AppCountButton(icon: Icons.remove, onTap: () => onChangePackageCount(packageCount - 1)),
                      SizedBox(
                        width: 72,
                        child: Center(child: Text('$packageCount', style: theme.textTheme.headlineMedium)),
                      ),
                      AppCountButton(icon: Icons.add, onTap: () => onChangePackageCount(packageCount + 1)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('총 중량', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Text(
                    '${(unitKg * packageCount).toStringAsFixed(0)}kg',
                    style: theme.textTheme.displayLarge?.copyWith(fontSize: 34),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('총 결제 금액', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Text(
                    '${formatPrice(totalAmount)}원',
                    style: theme.textTheme.displayLarge?.copyWith(fontSize: 34, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 11,
              child: FilledButton(onPressed: () {}, child: const Text('예약 담기')),
            ),
          ],
        ),
      ),
    );
  }
}
