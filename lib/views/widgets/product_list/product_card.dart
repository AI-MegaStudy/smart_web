import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../common/app_status_badge.dart';
import '../common/fruit_tile.dart';
import '../../../view_models/product_list/product_card_view_data.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  final ProductCardViewData product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: FruitTile(illustration: product.illustration)),
            const SizedBox(height: 16),
            AppStatusBadge(
              label: product.reserveStatus,
              backgroundColor: product.reserveColor,
              textColor: product.reserveTextColor,
            ),
            const SizedBox(height: 14),
            Text(product.name, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 10),
            Text(product.subtitle, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 12),
            Text('수확 예정: ${product.harvestWindow}', style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text(
              product.availableLabel,
              style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.primary),
            ),
            const Spacer(),
            FilledButton(
              onPressed: onTap,
              child: Text(onTap == null ? '준비 중' : '상세 보기'),
            ),
            const SizedBox(height: 12),
            Text(
              '${formatPrice(product.price)}원 / ${formatKg(product.unitKg)}kg',
              style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
