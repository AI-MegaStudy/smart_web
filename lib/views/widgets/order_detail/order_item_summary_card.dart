import 'package:flutter/material.dart';

import '../common/fruit_tile.dart';

class OrderItemSummaryCard extends StatelessWidget {
  const OrderItemSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Row(
          children: [
            const SizedBox(
              width: 190,
              height: 190,
              child: FruitTile(illustration: FruitIllustration.apple),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('청송 부사 사과 5kg', style: theme.textTheme.displayLarge?.copyWith(fontSize: 28)),
                  const SizedBox(height: 14),
                  Text('수확 예정: 2026.10.12 ~ 10.18', style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  Text('수량: 2박스  총액: 81,000원', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 18),
                  Text('결제 완료 후 산지 확인을 거쳐 배송 중입니다.', style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
