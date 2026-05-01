import 'package:flutter/material.dart';
import 'package:smart_web/yeeun/vm/product_view_model.dart';

import '../../core/app_colors.dart';
import '../../core/responsive.dart';
import '../widgets/app_header.dart';
import '../widgets/product_card.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final products = ProductViewModel().products;
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(
            title: '상품 목록',
            icon: Icons.inventory_2_outlined,
            showHome: true,
            actionText: '예약함',
            actionRoute: '/cart',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Responsive.maxWidth(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '수확 예정 상품',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '사과 품종과 수확 예정 범위를 함께 확인',
                        style: TextStyle(
                          fontSize: 29,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        '예약 가능한 상품을 우선 표시합니다. 패키지는 시즌 사과 판매 단위인 1kg, 3kg, 5kg, 7.5kg, 10kg 중 선택합니다.',
                        style: TextStyle(fontSize: 14, height: 1.45),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          _FilterChip(label: '전체', selected: true),
                          _FilterChip(label: '후지'),
                          _FilterChip(label: '홍로'),
                          _FilterChip(label: '시나노골드'),
                          _FilterChip(label: '1kg'),
                          _FilterChip(label: '3kg'),
                          _FilterChip(label: '5kg', selected: true),
                          _FilterChip(label: '7.5kg'),
                          _FilterChip(label: '10kg'),
                          _FilterChip(label: '잔여 많은 순'),
                        ],
                      ),
                      const SizedBox(height: 22),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isMobile ? 1 : 3,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                          childAspectRatio: isMobile ? 1.05 : 0.68,
                        ),
                        itemBuilder: (_, index) {
                          return ProductCard(product: products[index]);
                        },
                      ),
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
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _FilterChip({
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xffCFEFDB) : Colors.white,
        border: Border.all(
          color: selected ? const Color(0xff9AC9A8) : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
      ),
    );
  }
}
