import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../widgets/order_detail/order_item_summary_card.dart';
import '../../widgets/order_detail/order_notice_card.dart';
import '../../widgets/order_detail/order_return_status_card.dart';
import '../../widgets/order_detail/order_shipping_card.dart';
import '../../widgets/order_detail/order_timeline_card.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({
    super.key,
    required this.timelineSteps,
  });

  final List<String> timelineSteps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('주문 상세', style: theme.textTheme.displayLarge),
        const SizedBox(height: 10),
        Text(
          'ORD-20261001-0001',
          style: theme.textTheme.headlineMedium?.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 28),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 15,
              child: OrderTimelineCard(
                currentStep: 4,
                steps: timelineSteps,
              ),
            ),
            const SizedBox(width: 24),
            const Expanded(
              flex: 9,
              child: Column(
                children: [
                  OrderShippingCard(),
                  SizedBox(height: 24),
                  OrderNoticeCard(),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Row(
          children: [
            Expanded(
              flex: 15,
              child: OrderItemSummaryCard(),
            ),
            SizedBox(width: 24),
            Expanded(
              flex: 9,
              child: OrderReturnStatusCard(),
            ),
          ],
        ),
      ],
    );
  }
}
