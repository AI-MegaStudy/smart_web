import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../widgets/brand_app_bar_title.dart';

class ReturnCompletePage extends StatelessWidget {
  const ReturnCompletePage({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context) {
    final orderNumber = 'ORD-20261012-${orderId.toString().padLeft(3, '0')}';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 72,
        titleSpacing: 14,
        title: const BrandAppBarTitle(),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F1E5), Color(0xFFEEF4EE), Color(0xFFF7F7F1)],
            stops: [0, 0.48, 1],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: _CompleteCard(orderNumber: orderNumber),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompleteCard extends StatelessWidget {
  const _CompleteCard({required this.orderNumber});

  final String orderNumber;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE3DD)),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F102016),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.assignment_turned_in_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 74,
            ),
            const SizedBox(height: 18),
            Text(
              '반품 요청이 접수되었습니다',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF163B2B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$orderNumber 주문의 반품 요청을 확인했습니다. 상품 상태 확인 후 환불 가능 금액과 다음 절차를 안내해드립니다.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.5,
                color: const Color(0xFF5F6C62),
              ),
            ),
            const SizedBox(height: 24),
            const _StatusNotice(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    label: '접수 상태',
                    value: '반품 접수',
                    icon: Icons.fact_check_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoTile(
                    label: '확인 안내',
                    value: '농가 확인 후 안내',
                    icon: Icons.notifications_active_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  ),
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('홈으로'),
                ),
                FilledButton.icon(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.myOrders,
                    (route) => route.settings.name == AppRoutes.home,
                  ),
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: const Text('내 주문 보기'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusNotice extends StatelessWidget {
  const _StatusNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F8F3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD4E5D7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF0F6A3E)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '사진과 상세 사유를 바탕으로 상품 상태를 확인합니다. 반품 가능 여부와 환불 금액은 확인이 끝난 뒤 안내됩니다.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF31513C),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E7DE)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 10),
          Text(
            value,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0xFF657166)),
          ),
        ],
      ),
    );
  }
}
