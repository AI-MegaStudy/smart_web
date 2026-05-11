import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../data/models/harvest_slot_model.dart';
import 'status_badge.dart';

class HarvestSlotCard extends StatelessWidget {
  const HarvestSlotCard({
    super.key,
    required this.slot,
    required this.packageUnitKg,
    required this.packagePrice,
    required this.availablePackageCount,
    required this.selected,
    required this.onTap,
  });

  final HarvestSlotModel slot;
  final double packageUnitKg;
  final int packagePrice;
  final int availablePackageCount;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final customerNotice = _customerNoticeForDisplay(slot.customerNotice);

    return Card(
      color: selected ? const Color(0xFFE9F4EC) : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${slot.harvestStartLabel}-${slot.harvestEndLabel}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (selected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  else
                    const StatusBadge(label: '예약 가능'),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SlotChip(label: '${formatKg(packageUnitKg)}kg 박스'),
                  _SlotChip(label: '잔여 $availablePackageCount박스'),
                  _SlotChip(label: formatPrice(packagePrice)),
                ],
              ),
              if (customerNotice.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  customerNotice,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                    color: const Color(0xFF5F6C62),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _customerNoticeForDisplay(String notice) {
    final trimmed = notice.trim();
    if (RegExp(
      r'^QA\s*수확\s*슬롯\s*\d*$',
      caseSensitive: false,
    ).hasMatch(trimmed)) {
      return '';
    }
    return trimmed;
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE0E6DD)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: const Color(0xFF4B584D),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
