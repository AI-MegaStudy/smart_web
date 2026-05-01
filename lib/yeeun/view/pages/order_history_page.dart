import 'package:flutter/material.dart';
import 'package:smart_web/yeeun/vm/product_view_model.dart';

import '../../core/app_colors.dart';
import '../../core/responsive.dart';
import '../widgets/app_header.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final products = ProductViewModel().products;

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(
            title: '내 주문',
            icon: Icons.person_outline,
            showHome: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 32, 18, 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Responsive.maxWidth(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '주문 내역',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '최근 예약 주문',
                        style: TextStyle(
                          fontSize: 29,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      _OrderRow(
                        imageUrl: products[0].imageUrl,
                        orderNo: 'ORD-20261012-008',
                        title: '후지 사과 외 1건',
                        date: '2026.10.12',
                        status: '농가 확인 중 · 110,000원',
                        statusColor: const Color(0xffBFEAF5),
                        linked: true,
                      ),
                      _OrderRow(
                        imageUrl: products[2].imageUrl,
                        orderNo: 'ORD-20260928-014',
                        title: '시나노골드 사과 4kg',
                        date: '2026.09.28',
                        status: '배송 중 · 46,000원',
                        statusColor: const Color(0xffBFEAF5),
                      ),
                      _OrderRow(
                        imageUrl: products[1].imageUrl,
                        orderNo: 'ORD-20260905-002',
                        title: '홍로 사과 3kg',
                        date: '2026.09.05',
                        status: '배송 완료 · 32,000원',
                        statusColor: const Color(0xffFFE48A),
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

class _OrderRow extends StatelessWidget {
  final String imageUrl;
  final String orderNo;
  final String title;
  final String date;
  final String status;
  final Color statusColor;
  final bool linked;

  const _OrderRow({
    required this.imageUrl,
    required this.orderNo,
    required this.title,
    required this.date,
    required this.status,
    required this.statusColor,
    this.linked = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: linked ? () => Navigator.pushNamed(context, '/order-detail') : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(imageUrl, width: 60, height: 60, fit: BoxFit.cover),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orderNo,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: linked ? Colors.blue : AppColors.text,
                      decoration:
                          linked ? TextDecoration.underline : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 12)),
                      Text(date, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                status,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
