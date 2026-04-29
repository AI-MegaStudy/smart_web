import 'package:flutter/material.dart';

import '../common/app_info_line.dart';

class OrderShippingCard extends StatelessWidget {
  const OrderShippingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('배송 정보', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 28),
            const AppInfoLine(label: '택배사', value: '하베스트 택배'),
            const SizedBox(height: 18),
            const AppInfoLine(label: '송장번호', value: 'HS-202610-000123'),
            const SizedBox(height: 28),
            FilledButton(onPressed: () {}, child: const Text('배송 조회')),
          ],
        ),
      ),
    );
  }
}
