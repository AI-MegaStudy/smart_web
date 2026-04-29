import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';

class OrderNoticeCard extends StatelessWidget {
  const OrderNoticeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('주문 안내', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E6),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFF1C375)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '수확 예정 기간은 산지 상황에 따라 조정될 수 있습니다.',
                    style: theme.textTheme.titleLarge?.copyWith(color: const Color(0xFFE09024)),
                  ),
                  const SizedBox(height: 10),
                  Text('변경이 발생하면 주문 상태 화면에서 안내됩니다.', style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
            const SizedBox(height: 22),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
              ),
              child: const Text('반품 요청'),
            ),
          ],
        ),
      ),
    );
  }
}
