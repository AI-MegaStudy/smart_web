import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../../view_models/product_detail/harvest_slot_view_data.dart';
import '../common/app_status_badge.dart';
import '../common/fruit_tile.dart';

class HarvestSlotCard extends StatelessWidget {
  const HarvestSlotCard({
    super.key,
    required this.slot,
    required this.selected,
    this.onSelect,
  });

  final HarvestSlotViewData slot;
  final bool selected;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFF3FAF1) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: selected ? AppColors.primary : AppColors.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppStatusBadge(
            label: slot.status,
            backgroundColor: slot.disabled ? const Color(0xFFFBE6E6) : const Color(0xFFE7F5E8),
            textColor: slot.disabled ? const Color(0xFFC8574C) : AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(slot.label, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 10),
          Text(slot.window, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 10),
          Text(
            '예약 가능 ${slot.remainingKg}kg',
            style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          Text(
            '${formatPrice(slot.price)}원 / ${formatKg(slot.unitKg.toDouble())}kg',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: slot.disabled
                ? OutlinedButton(onPressed: null, child: const Text('선택 불가'))
                : FilledButton(onPressed: onSelect, child: Text(selected ? '선택됨' : '선택')),
          ),
        ],
      ),
    );
  }
}
