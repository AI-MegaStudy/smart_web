import 'package:flutter/material.dart';

import '../../widgets/product_list/product_card.dart';
import '../../widgets/product_list/product_list_filter_bar.dart';
import '../../widgets/product_list/product_list_intro.dart';
import '../../../view_models/product_list/product_card_view_data.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({
    super.key,
    required this.products,
    required this.onOpenDetail,
  });

  final List<ProductCardViewData> products;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProductListIntro(),
        const SizedBox(height: 28),
        const ProductListFilterBar(),
        const SizedBox(height: 30),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 22,
            mainAxisSpacing: 22,
            childAspectRatio: 0.79,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              onTap: index == 0 ? onOpenDetail : null,
            );
          },
        ),
      ],
    );
  }
}
