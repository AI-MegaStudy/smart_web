import 'package:flutter/material.dart';

import '../../../view_models/product_detail/harvest_slot_view_data.dart';
import '../../widgets/product_detail/harvest_slot_card.dart';
import '../../widgets/product_detail/product_detail_hero_section.dart';
import '../../widgets/product_detail/product_info_card.dart';
import '../../widgets/product_detail/reservation_summary_card.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({
    super.key,
    required this.slots,
    required this.selectedSlot,
    required this.packageCount,
    required this.onSelectSlot,
    required this.onChangePackageCount,
  });

  final List<HarvestSlotViewData> slots;
  final int selectedSlot;
  final int packageCount;
  final ValueChanged<int> onSelectSlot;
  final ValueChanged<int> onChangePackageCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final slot = slots[selectedSlot];
    final totalAmount = slot.price * packageCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProductDetailHeroSection(),
        const SizedBox(height: 38),
        Text('수확 슬롯 선택', style: theme.textTheme.headlineLarge),
        const SizedBox(height: 22),
        Row(
          children: [
            for (var i = 0; i < slots.length; i++) ...[
              Expanded(
                child: HarvestSlotCard(
                  slot: slots[i],
                  selected: i == selectedSlot,
                  onSelect: slots[i].disabled ? null : () => onSelectSlot(i),
                ),
              ),
              if (i != slots.length - 1) const SizedBox(width: 22),
            ],
          ],
        ),
        const SizedBox(height: 28),
        ReservationSummaryCard(
          packageCount: packageCount,
          unitKg: slot.unitKg,
          totalAmount: totalAmount,
          onChangePackageCount: onChangePackageCount,
        ),
        const SizedBox(height: 28),
        const Row(
          children: [
            Expanded(
              child: ProductInfoCard(
                title: '선별 기준',
                body: 'A/B/C 등급 기준으로 선별하며, 출하 직전 상태를 다시 한 번 확인합니다.',
              ),
            ),
            SizedBox(width: 22),
            Expanded(
              child: ProductInfoCard(
                title: '농장 이야기',
                body: '청송 고랭지 과수원에서 재배한 사과로, 수확 후 바로 선별해 신선하게 발송합니다.',
              ),
            ),
            SizedBox(width: 22),
            Expanded(
              child: ProductInfoCard(
                title: '배송/반품',
                body: '결제 완료 후 순차 발송되며, 배송 완료 주문에 한해 반품 신청이 가능합니다.',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
