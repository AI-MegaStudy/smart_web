import 'package:flutter/material.dart';
import 'package:smart_web/yeeun/model/product_model.dart';
import 'package:smart_web/yeeun/vm/product_view_model.dart';

import '../../core/app_colors.dart';
import '../../core/responsive.dart';
import '../widgets/app_header.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final Map<String, int> _quantities = {'1': 2, '2': 1};

  @override
  Widget build(BuildContext context) {
    final products = ProductViewModel().products.take(2).toList();
    final isMobile = Responsive.isMobile(context);
    final total = products.fold<int>(
      0,
      (sum, product) => sum + product.price * (_quantities[product.id] ?? 1),
    );
    final totalCount = products.fold<int>(
      0,
      (sum, product) => sum + (_quantities[product.id] ?? 1),
    );

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(
            title: '예약함',
            icon: Icons.shopping_cart_outlined,
            showHome: true,
            actionText: '주문서 작성',
            actionRoute: '/order-form',
          ),
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
                            _CartItems(
                              products: products,
                              quantities: _quantities,
                              onChange: _changeQuantity,
                            ),
                            const SizedBox(height: 18),
                            _CartSummary(totalCount: totalCount, total: total),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _CartItems(
                                products: products,
                                quantities: _quantities,
                                onChange: _changeQuantity,
                              ),
                            ),
                            const SizedBox(width: 18),
                            SizedBox(
                              width: 280,
                              child: _CartSummary(
                                totalCount: totalCount,
                                total: total,
                              ),
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

  void _changeQuantity(String productId, int delta) {
    setState(() {
      final current = _quantities[productId] ?? 1;
      _quantities[productId] = (current + delta).clamp(1, 9);
    });
  }
}

class _CartItems extends StatelessWidget {
  final List<ProductModel> products;
  final Map<String, int> quantities;
  final void Function(String productId, int delta) onChange;

  const _CartItems({
    required this.products,
    required this.quantities,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '예약함',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          ...products.map(
            (product) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      product.imageUrl,
                      width: 72,
                      height: 58,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text('${product.harvestDate} 수확 예정'),
                      ],
                    ),
                  ),
                  _StepperBox(
                    value: quantities[product.id] ?? 1,
                    onMinus: () => onChange(product.id, -1),
                    onPlus: () => onChange(product.id, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final int totalCount;
  final int total;

  const _CartSummary({
    required this.totalCount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('예약 정보', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          _PriceLine(label: '상품 수량', value: '$totalCount박스'),
          const _PriceLine(label: '배송 예정', value: '10월 중순'),
          const Divider(height: 28),
          _PriceLine(label: '합계', value: '${_formatPrice(total)}원', strong: true),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/order-form'),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('주문서 작성'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperBox extends StatelessWidget {
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _StepperBox({
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _smallButton(Icons.remove, onMinus),
        Container(
          width: 36,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
          child: Text('$value', style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
        _smallButton(Icons.add, onPlus),
      ],
    );
  }

  Widget _smallButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 14),
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  final String label;
  final String value;
  final bool strong;

  const _PriceLine({
    required this.label,
    required this.value,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              color: strong ? AppColors.primary : AppColors.text,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    border: Border.all(color: AppColors.border),
    borderRadius: BorderRadius.circular(8),
  );
}

String _formatPrice(int price) {
  return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]},',
      );
}
