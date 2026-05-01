import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../widgets/app_header.dart';

class ReservationConfirmPage extends StatelessWidget {
  const ReservationConfirmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: Center(
              child: Container(
                width: 520,
                padding: const EdgeInsets.all(34),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 34,
                      backgroundColor: Color(0xffD8F3E3),
                      child: Icon(
                        Icons.check,
                        color: AppColors.primary,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      '예약 주문이 완료되었습니다',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '주문번호 ORD-20261012-008의 예약이 접수되었습니다. 수확이 시작되면 배송 준비 상태가 업데이트됩니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: const [
                        Expanded(
                          child: _ResultBox(label: '결제 금액', value: '110,000원'),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _ResultBox(label: '상태', value: '예약 완료'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/'),
                            icon: const Icon(Icons.home_outlined),
                            label: const Text('홈으로'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/orders'),
                            icon: const Icon(Icons.receipt_long_outlined),
                            label: const Text('주문 내역'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
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
}

class _ResultBox extends StatelessWidget {
  final String label;
  final String value;

  const _ResultBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
