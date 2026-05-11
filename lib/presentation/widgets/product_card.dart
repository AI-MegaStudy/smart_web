import 'package:flutter/material.dart';

import '../../data/models/product_model.dart';
import 'price_text.dart';
import 'status_badge.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, this.onTap});

  final ProductModel product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 520;
        final cardPadding = isCompact ? 12.0 : 14.0;
        final chipSpacing = isCompact ? 6.0 : 8.0;

        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: isCompact ? 16 / 7.8 : 16 / 8.4,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFE3E9DF),
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          if (product.isLowStock)
                            const StatusBadge(label: '잔여 수량 적음', warning: true)
                          else if (!product.isReservable)
                            const _StateLabel(label: '다음 수확 준비 중'),
                        ],
                      ),
                      SizedBox(height: isCompact ? 7 : 8),
                      Wrap(
                        spacing: chipSpacing,
                        runSpacing: chipSpacing,
                        children: product.isReservable
                            ? [
                                StatusBadge(
                                  label:
                                      '${product.harvestStartLabel}-${product.harvestEndLabel} 수확 예정',
                                ),
                                _MetaChip(
                                  label:
                                      '잔여 ${product.availableKg.toStringAsFixed(product.availableKg % 1 == 0 ? 0 : 1)}kg',
                                  compact: isCompact,
                                ),
                              ]
                            : [
                                const StatusBadge(label: '수확 일정 준비 중'),
                                _MetaChip(
                                  label: '확정 후 예약 가능',
                                  compact: isCompact,
                                ),
                              ],
                      ),
                      SizedBox(height: isCompact ? 8 : 10),
                      Text(
                        product.farmLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF657166),
                        ),
                      ),
                      SizedBox(height: isCompact ? 5 : 6),
                      if (product.isReservable)
                        PriceText(price: product.price)
                      else
                        Text(
                          '수확 일정 확정 후 안내',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: const Color(0xFF2F6B4E),
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.compact});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4EE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: const Color(0xFF4B584D),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StateLabel extends StatelessWidget {
  const _StateLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E0),
        border: Border.all(color: const Color(0xFFE0B45B)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: const Color(0xFF7A4F00),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
