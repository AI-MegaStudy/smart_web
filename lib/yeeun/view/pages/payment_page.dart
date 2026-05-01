import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/responsive.dart';
import '../widgets/app_header.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Responsive.maxWidth(context),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: _cardDecoration(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '결제',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '입금 계좌',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '농협 **** 4810 2027',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '예금주: 하베스트슬롯',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xfffff8df),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xffffe3a5)),
                              ),
                              child: const Text('입금 확인 후 예약 상태가 결제 완료로 변경됩니다.'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    SizedBox(
                      width: 300,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: _cardDecoration(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '주문 ORD-20261012-008',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                            const Divider(height: 28),
                            const _PriceLine(label: '상품 금액', value: '110,000원'),
                            const _PriceLine(label: '배송비', value: '무료'),
                            const _PriceLine(label: '할인 금액', value: '0원'),
                            const Divider(height: 28),
                            const _PriceLine(
                              label: '승인 금액',
                              value: '110,000원',
                              strong: true,
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/reservation-confirm',
                                ),
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text('결제 완료'),
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
              fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
              color: strong ? AppColors.primary : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
