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
          const AppHeader(
            title: '상품 상세',
            icon: Icons.apple,
            showBack: true,
            actionText: '담기',
            actionRoute: '/cart',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 36),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Responsive.maxWidth(context),
                  ),
                  child: isMobile
                      ? Column(
                          children: [
                            _ProductPhoto(product: product),
                            const SizedBox(height: 18),
                            _ReservationPanel(product: product),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 11,
                              child: _ProductPhoto(product: product),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              flex: 10,
                              child: _ReservationPanel(product: product),
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

class _ProductPhoto extends StatelessWidget {
  final ProductModel product;

  const _ProductPhoto({required this.product});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.asset(
        product.imageUrl,
        height: 705,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _ReservationPanel extends StatelessWidget {
  final ProductModel product;

  const _ReservationPanel({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '수확 슬롯 예약',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            product.name.replaceAll('5kg', '예약'),
            style: const TextStyle(fontSize: 31, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Text(product.description),
          const SizedBox(height: 6),
          const Text(
            '패키지 단위 선택',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PackageOption(weight: '1kg', sub: '소포장'),
              _PackageOption(weight: '3kg', sub: '가정용'),
              _PackageOption(weight: '5kg', sub: '인기', selected: true),
              _PackageOption(weight: '7.5kg', sub: '넉넉한 양'),
              _PackageOption(weight: '10kg', sub: '대용량'),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '${_formatPrice(product.price)}원 / 5kg 박스',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '수확 슬롯 선택',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          _HarvestSlot(
            title: '${product.harvestDate} 수확 예정',
            selected: true,
            detail: '확정 300kg · 예약 70kg · 판매 45kg',
            remain: '잔여 ${product.stockKg}kg',
            progress: 0.38,
          ),
          const SizedBox(height: 10),
          const _HarvestSlot(
            title: '10.19~10.25 수확 예정',
            detail: '확정 180kg',
            remain: '잔여 158kg',
            progress: 0.16,
          ),
          const SizedBox(height: 22),
          const Text(
            '박스 수량 선택',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          const _QuantitySelector(),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xffEEF0EB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '선택한 예약\n5kg 박스 2개, 총 10kg\n10.12-10.18 수확분으로 담깁니다.',
              style: TextStyle(height: 1.7, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xffBFEAF5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '농가가 확정한 수확 예정 범위입니다. 기상과 생육 상황에 따라 일정이 조정될 수 있습니다.',
              style: TextStyle(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }
}

class _PackageOption extends StatelessWidget {
  final String weight;
  final String sub;
  final bool selected;

  const _PackageOption({
    required this.weight,
    required this.sub,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color: selected ? const Color(0xffB3EFCB) : Colors.white,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(weight, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text(sub, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}

class _HarvestSlot extends StatelessWidget {
  final String title;
  final String detail;
  final String remain;
  final double progress;
  final bool selected;

  const _HarvestSlot({
    required this.title,
    required this.detail,
    required this.remain,
    required this.progress,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selected ? const Color(0xffDCF7E7) : Colors.white,
        border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              Text(detail, style: const TextStyle(fontSize: 11)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xffAEE9F8) : const Color(0xffFFE48A),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  remain,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              color: AppColors.primary,
              backgroundColor: AppColors.border,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final value = index + 1;
        final selected = value == 2;
        return Container(
          width: 36,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xffCFEFDB) : Colors.white,
            border: Border.all(color: AppColors.text),
            borderRadius: BorderRadius.horizontal(
              left: index == 0 ? const Radius.circular(16) : Radius.zero,
              right: index == 4 ? const Radius.circular(16) : Radius.zero,
            ),
          ),
          child: Text(
            '$value',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        );
      }),
    );
  }
}
