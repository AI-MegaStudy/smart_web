import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/responsive.dart';
import '../widgets/app_header.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(
            title: '주문 상세',
            icon: Icons.account_tree_outlined,
            actionText: '배송 중',
            actionRoute: '/orders',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(44, 34, 44, 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: Responsive.maxWidth(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '주문 진행 상태',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '주문, 결제, 발주, 선별, 배송 상태',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      isMobile
                          ? Column(
                              children: [
                                const _ProgressCard(),
                                const SizedBox(height: 18),
                                _SummaryCard(),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Expanded(flex: 3, child: _ProgressCard()),
                                const SizedBox(width: 18),
                                SizedBox(width: 330, child: _SummaryCard()),
                              ],
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

class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('진행 현황', style: TextStyle(fontWeight: FontWeight.w900)),
          SizedBox(height: 12),
          _ProgressStep(
            title: '결제 완료',
            detail: '카드 결제가 승인되었습니다.',
            time: '10.12 14:02',
            done: true,
          ),
          _ProgressStep(
            title: '농가 승인 완료',
            detail: '점주가 수확 가능 수량을 승인했습니다.',
            time: '10.12 16:20',
            done: true,
          ),
          _ProgressStep(
            title: '선별 완료',
            detail: '사과 선별도 선별 후 출고 준비 완료.',
            time: '10.18 09:40',
            done: true,
          ),
          _ProgressStep(
            title: '배송 중',
            detail: 'CJ대한통운 5891-1202-4810',
            time: '현재',
            icon: Icons.local_shipping_outlined,
            done: true,
          ),
          _ProgressStep(
            title: '배송 완료',
            detail: '완료 후 반품 신청 가능',
            time: '예정',
          ),
        ],
      ),
    );
  }
}

class _ProgressStep extends StatelessWidget {
  final String title;
  final String detail;
  final String time;
  final bool done;
  final IconData icon;

  const _ProgressStep({
    required this.title,
    required this.detail,
    required this.time,
    this.done = false,
    this.icon = Icons.check,
  });

  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.primary : const Color(0xffD7DDD2);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: color,
            child: Icon(icon, size: 15, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 7),
                Text(detail, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '주문 요약',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          const _SummaryLine(label: '주문번호', value: 'ORD-20261012-008'),
          const _SummaryLine(label: '수확 범위', value: '10.12-10.18'),
          const _SummaryLine(label: '받는 분', value: '홍길동'),
          const _SummaryLine(label: '결제 금액', value: '110,000원'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xffBFEAF5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '수확 일정은 기상과 생육 상황에 따라 조정될 수 있습니다.',
              style: TextStyle(height: 1.5),
            ),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/return-request'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.text,
                side: const BorderSide(color: AppColors.text),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('반품 신청'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    border: Border.all(color: AppColors.border),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 7,
        offset: const Offset(0, 3),
      ),
    ],
  );
}
