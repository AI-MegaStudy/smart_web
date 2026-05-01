import 'package:flutter/material.dart';
import 'package:smart_web/yeeun/vm/product_view_model.dart';

import '../../core/app_colors.dart';
import '../../core/responsive.dart';
import '../widgets/app_header.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final products = ProductViewModel().products.take(2).toList();
    final total = products.fold<int>(0, (sum, product) => sum + product.price);

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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: _cardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '예약함',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...products.map(
                                (p) => Container(
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
                                          p.imageUrl,
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
                                              p.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text('${p.harvestDate} 수확 예정'),
                                          ],
                                        ),
                                      ),
                                      _StepperBox(value: p.id == '1' ? '2' : '1'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      SizedBox(
                        width: 280,
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: _cardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '예약 정보',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 16),
                              _PriceLine(label: '상품 수량', value: '3kg'),
                              const _PriceLine(label: '배송 예정', value: '10월 중순'),
                              const Divider(height: 28),
                              _PriceLine(
                                label: '합계',
                                value: '${_formatPrice(total)}원',
                                strong: true,
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    '/order-form',
                                  ),
                                  icon: const Icon(Icons.check_circle_outline),
                                  label: const Text('예약 확인'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
}

class _StepperBox extends StatelessWidget {
  final String value;

  const _StepperBox({required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _smallButton(Icons.remove),
        Container(
          width: 36,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
          ),
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
        _smallButton(Icons.add),
      ],
    );
  }

  Widget _smallButton(IconData icon) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(icon, size: 14),
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
