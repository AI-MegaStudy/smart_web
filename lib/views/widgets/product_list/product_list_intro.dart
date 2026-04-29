import 'package:flutter/material.dart';

class ProductListIntro extends StatelessWidget {
  const ProductListIntro({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('지금 예약 가능한 제철 과수 상품', style: theme.textTheme.displayLarge),
        const SizedBox(height: 14),
        Text(
          '농장주가 확정한 수확 일정과 예약 가능 수량 기준으로 상품을 고를 수 있습니다.',
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}
