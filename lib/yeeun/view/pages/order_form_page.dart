import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/responsive.dart';
import '../widgets/app_header.dart';

class OrderFormPage extends StatelessWidget {
  const OrderFormPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: _cardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '주문서',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _input('수령인', initialValue: '김유진'),
                              _input('연락처', initialValue: '010-1111-2222'),
                              _input('배송 주소', initialValue: '서울시 강남구 디지털로 123'),
                              _input('배송 요청사항', initialValue: '문 앞에 놓아주세요'),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '예약 RES-20261012-005',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                              const Divider(height: 28),
                              const _InfoLine(label: '상품 수', value: '2종'),
                              const _InfoLine(label: '예약 수량', value: '3박스'),
                              const _InfoLine(label: '예상 배송', value: '10월 중순'),
                              const Divider(height: 28),
                              const _InfoLine(label: '주문 금액', value: '110,000원', strong: true),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      Navigator.pushNamed(context, '/payment'),
                                  icon: const Icon(Icons.arrow_forward),
                                  label: const Text('결제 진행'),
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

  Widget _input(String label, {required String initialValue}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
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

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;
  final bool strong;

  const _InfoLine({
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
