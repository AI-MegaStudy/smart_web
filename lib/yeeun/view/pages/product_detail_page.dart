import 'package:flutter/material.dart';
import 'package:smart_web/yeeun/vm/product_view_model.dart';
import '../../core/app_colors.dart';
import '../../core/responsive.dart';
import '../widgets/app_header.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final product = ProductViewModel().products.first;
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
                          children: [
                            _image(product.imageUrl),
                            const SizedBox(height: 20),
                            _info(context, product),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _image(product.imageUrl)),
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

  Widget _image(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.asset(
        imageUrl,
        height: 420,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _info(BuildContext context, dynamic product) {
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
        Text('${product.harvestDate} 수확 예정'),
        const SizedBox(height: 16),
        Text(
          '${product.price}원',
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
          child: const Text('수확일은 날씨와 농장 상황에 따라 일부 변동될 수 있습니다.'),
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
}
