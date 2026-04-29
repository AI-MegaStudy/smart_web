import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../common/app_status_badge.dart';
import '../common/fruit_tile.dart';

class ProductDetailHeroSection extends StatelessWidget {
  const ProductDetailHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 11,
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: 420,
              child: const FruitHeroCard(illustration: FruitIllustration.apple),
            ),
          ),
        ),
        const SizedBox(width: 28),
        Expanded(
          flex: 13,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppStatusBadge(
                    label: '예약 가능',
                    backgroundColor: Color(0xFFE7F5E8),
                    textColor: Color(0xFF3B873E),
                  ),
                  const SizedBox(height: 18),
                  Text('[예약 상품] 청송 부사 사과 5kg', style: theme.textTheme.displayLarge),
                  const SizedBox(height: 10),
                  Text('아삭한 식감과 산뜻한 단맛이 살아있는 제철 과수 상품입니다.', style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  Text(
                    '39,000원',
                    style: theme.textTheme.displayLarge?.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '수확 일정과 예약 가능 수량은 산지에서 확정한 정보 기준으로 안내됩니다.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E6),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFF3C37C)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '수확 예정 기간 안내',
                          style: theme.textTheme.titleLarge?.copyWith(color: const Color(0xFFE09024)),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '기상과 생육 상황에 따라 일정이 일부 조정될 수 있으며, 변경 시 주문 상태 화면에서 안내됩니다.',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
