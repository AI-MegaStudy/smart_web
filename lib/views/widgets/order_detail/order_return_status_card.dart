import 'package:flutter/material.dart';

import '../common/app_status_badge.dart';

class OrderReturnStatusCard extends StatelessWidget {
  const OrderReturnStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('반품/환불 상태', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 18),
            const AppStatusBadge(
              label: '반품 요청 없음',
              backgroundColor: Color(0xFFE7F5E8),
              textColor: Color(0xFF3B873E),
            ),
            const SizedBox(height: 18),
            Text(
              '배송 완료 주문은 반품 요청이 가능하며, 접수 이후 환불 상태도 이 영역에서 확인할 수 있습니다.',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
