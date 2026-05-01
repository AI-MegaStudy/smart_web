import 'package:flutter/material.dart';
import 'package:smart_web/yeeun/model/product_model.dart';
import 'package:smart_web/yeeun/vm/product_view_model.dart';

import '../../core/app_colors.dart';
import '../../core/responsive.dart';
import '../widgets/app_header.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)?.settings.arguments as String?;
    final product = ProductViewModel().findById(productId);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Responsive.maxWidth(context),
                  ),
                  child: isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _image(product),
                            const SizedBox(height: 20),
                            _info(context, product),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _image(product)),
                            const SizedBox(width: 32),
                            Expanded(child: _info(context, product)),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _image(ProductModel product) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.asset(
        product.imageUrl,
        height: 420,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _info(BuildContext context, ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '예약 가능 상품',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.name,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        Text(product.description, style: const TextStyle(height: 1.5)),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _InfoBadge(icon: Icons.event_available, text: product.harvestDate),
            _InfoBadge(icon: Icons.inventory_2_outlined, text: '${product.stockKg}kg 남음'),
            const _InfoBadge(icon: Icons.local_shipping_outlined, text: '수확 후 순차 배송'),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          '${_formatPrice(product.price)}원',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xfffff8df),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xffffe3a5)),
          ),
          child: const Text(
            '수확일은 날씨와 농장 상황에 따라 일부 조정될 수 있습니다. 변경 시 예약자에게 먼저 안내합니다.',
            style: TextStyle(height: 1.45),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/cart'),
                child: const Text('예약함 담기'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/order-form'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('예약 주문하기'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
