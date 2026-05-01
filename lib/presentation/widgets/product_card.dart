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
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
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
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (product.isLowStock)
                        const StatusBadge(label: '잔여 수량 적음', warning: true),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      StatusBadge(
                        label:
                            '${product.harvestStartLabel}-${product.harvestEndLabel} 수확 예정',
                      ),
                      _MetaChip(
                        label:
                            '잔여 ${product.availableKg.toStringAsFixed(product.availableKg % 1 == 0 ? 0 : 1)}kg',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    product.farmName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF657166),
                    ),
                  ),
                  const SizedBox(height: 8),
                  PriceText(price: product.price),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
