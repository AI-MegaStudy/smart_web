import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/utils/formatters.dart';
import '../../../demo/customer_coach_tour_manager.dart';
import '../../../demo/customer_demo_target_keys.dart';
import '../../view_models/order_complete_view_model.dart';
import '../../widgets/brand_app_bar_title.dart';
import '../../widgets/flow_status_badge.dart';
import '../../widgets/notice_box.dart';
import '../../widgets/status_badge.dart';

class OrderCompletePage extends StatefulWidget {
  const OrderCompletePage({super.key, required this.orderId});

  final int orderId;

  @override
  State<OrderCompletePage> createState() => _OrderCompletePageState();
}

class _OrderCompletePageState extends State<OrderCompletePage> {
  late final OrderCompleteViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = OrderCompleteViewModel(orderId: widget.orderId)..load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      CustomerCoachTourManager.instance.onPageReady(
        CustomerCoachTourStage.orderComplete,
        context,
      );
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 72,
        titleSpacing: 14,
        title: const BrandAppBarTitle(),
        actions: const [
          FlowStatusBadge(
            stepLabel: '예약 흐름 5/5',
            statusLabel: '주문 완료',
            icon: Icons.check_circle_outline,
          ),
        ],
      ),
      body: _ScreenBackground(
        child: AnimatedBuilder(
          animation: _viewModel,
          builder: (context, _) {
            if (_viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: _CompleteCard(viewModel: _viewModel),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ScreenBackground extends StatelessWidget {
  const _ScreenBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF5F1E5), Color(0xFFEEF4EE), Color(0xFFF7F7F1)],
          stops: [0, 0.48, 1],
        ),
      ),
      child: child,
    );
  }
}

class _CompleteCard extends StatelessWidget {
  const _CompleteCard({required this.viewModel});

  final OrderCompleteViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final errorMessage = viewModel.errorMessage;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE3DD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              errorMessage == null ? Icons.check_circle : Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 74,
            ),
            const SizedBox(height: 18),
            Text(
              errorMessage == null ? '예약 주문이 완료되었습니다' : '주문 정보를 확인 중입니다',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF163B2B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage ??
                  '${viewModel.orderNumber} 결제가 완료되었습니다. 농가가 수확 가능 수량을 확인한 뒤 주문 상세에서 진행 상태를 안내합니다.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.5,
                color: const Color(0xFF5F6C62),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusBadge(label: viewModel.statusLabel),
                const StatusBadge(label: '수확 직배송'),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _SummaryTile(
                    label: '주문번호',
                    value: viewModel.orderNumber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryTile(
                    label: '결제 금액',
                    value: formatPrice(viewModel.totalAmount),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const NoticeBox(
              message:
                  '결제 후 농가가 수확 가능 수량을 최종 확인합니다. 수확 일정은 기상과 생육 상황에 따라 조정될 수 있습니다.',
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
                  key: CustomerDemoTargetKeys.orderCompletePrimaryAction,
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.orderDetail,
                    arguments: viewModel.orderId,
                  ),
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: const Text('주문 상세 보기'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4EE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
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
