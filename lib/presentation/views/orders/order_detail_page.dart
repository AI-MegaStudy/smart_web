import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/local_basket_item_model.dart';
import '../../../data/models/order_model.dart';
import '../../view_models/order_detail_view_model.dart';
import '../../widgets/brand_app_bar_title.dart';
import '../../widgets/notice_box.dart';
import '../../widgets/status_badge.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final int orderId;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late final OrderDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = OrderDetailViewModel(orderId: widget.orderId)..load();
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
      ),
      body: _ScreenBackground(
        child: AnimatedBuilder(
          animation: _viewModel,
          builder: (context, _) {
            final order = _viewModel.order;
            if (_viewModel.isLoading || order == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _ConstrainedContent(child: _PageIntro(order: order)),
                ),
                SliverToBoxAdapter(
                  child: _ConstrainedContent(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 980;
                          final progress = _ProgressPanel(order: order);
                          final summary = _OrderSummary(order: order);

                          if (!isWide) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                progress,
                                const SizedBox(height: 18),
                                summary,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 6, child: progress),
                              const SizedBox(width: 18),
                              Expanded(flex: 4, child: summary),
                            ],
                          );
                        },
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

class _ConstrainedContent extends StatelessWidget {
  const _ConstrainedContent({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: child,
      ),
    );
  }
}

class _PageIntro extends StatelessWidget {
  const _PageIntro({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '주문 진행 상태',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            order.orderNumber,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF163B2B),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusBadge(label: order.orderStatusLabel),
              const StatusBadge(label: '수확 직배송'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final steps = [
      _ProgressStepData(
        label: '결제 완료',
        description: '카드 결제가 승인되었습니다.',
        time: '10.12 14:02',
        completed: true,
        current: false,
        icon: Icons.check,
      ),
      _ProgressStepData(
        label: '농가 승인 완료',
        description: '점주가 수확 가능 수량을 승인했습니다.',
        time: '10.12 16:20',
        completed: true,
        current: false,
        icon: Icons.check,
      ),
      _ProgressStepData(
        label: '선별 완료',
        description: '사과 신선도 선별 후 출고 준비 완료.',
        time: '10.18 09:40',
        completed: true,
        current: false,
        icon: Icons.check,
      ),
      _ProgressStepData(
        label: order.orderStatusLabel,
        description: '선별을 마친 사과가 배송지로 이동 중입니다.',
        time: '현재',
        completed: true,
        current: true,
        icon: Icons.local_shipping_outlined,
      ),
      const _ProgressStepData(
        label: '배송 완료',
        description: '완료 후 반품 신청 가능',
        time: '예정',
        completed: false,
        current: false,
        icon: Icons.check,
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE3DD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '진행 현황',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            for (var index = 0; index < steps.length; index += 1) ...[
              _ProgressStep(step: steps[index]),
              if (index != steps.length - 1)
                const Divider(height: 28, color: Color(0xFFDCE3DD)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProgressStepData {
  const _ProgressStepData({
    required this.label,
    required this.description,
    required this.time,
    required this.completed,
    required this.current,
    required this.icon,
  });

  final String label;
  final String description;
  final String time;
  final bool completed;
  final bool current;
  final IconData icon;
}

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({required this.step});

  final _ProgressStepData step;

  @override
  Widget build(BuildContext context) {
    final color = step.completed
        ? Theme.of(context).colorScheme.primary
        : const Color(0xFFB8C2B8);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: step.completed
              ? Icon(step.icon, color: Colors.white, size: 17)
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF101813),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                step.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4B584D),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          step.time,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF101813),
          ),
        ),
      ],
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE3DD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '주문 요약',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            for (final item in order.items) ...[
              _OrderItem(item: item),
              const SizedBox(height: 12),
            ],
            const Divider(height: 28),
            _SummaryRow(label: '받는 분', value: order.receiverName),
            const SizedBox(height: 10),
            _SummaryRow(label: '결제 금액', value: formatPrice(order.totalAmount)),
            const SizedBox(height: 10),
            _SummaryRow(
              label: '총 중량',
              value: '${formatKg(order.totalReservedKg)}kg',
            ),
            const SizedBox(height: 10),
            _SummaryRow(label: '택배사', value: order.carrierName),
            const SizedBox(height: 10),
            _SummaryRow(label: '송장번호', value: order.trackingNumber),
            const SizedBox(height: 18),
            const NoticeBox(message: '수확 일정은 기상과 생육 상황에 따라 조정될 수 있습니다.'),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.returnRequest,
                arguments: order.orderId,
              ),
              icon: const Icon(Icons.assignment_return_outlined),
              label: const Text('반품 신청'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderItem extends StatelessWidget {
  const _OrderItem({required this.item});

  final LocalBasketItemModel item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.productName,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          '${item.harvestStartLabel}-${item.harvestEndLabel} · ${item.packageCount}박스',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF657166)),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF657166)),
          ),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}
