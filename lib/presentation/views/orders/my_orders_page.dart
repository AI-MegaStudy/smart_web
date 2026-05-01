import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order_model.dart';
import '../../view_models/my_orders_view_model.dart';
import '../../widgets/brand_app_bar_title.dart';
import '../../widgets/status_badge.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  late final MyOrdersViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MyOrdersViewModel()..load();
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
            if (_viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: _ConstrainedContent(child: _PageIntro()),
                ),
                SliverToBoxAdapter(
                  child: _ConstrainedContent(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                      child: Column(
                        children: [
                          for (final order in _viewModel.orders) ...[
                            _OrderListItem(order: order),
                            const SizedBox(height: 12),
                          ],
                        ],
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
  const _PageIntro();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '주문 상태 추적',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '최근 예약 주문',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF163B2B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '예약 주문의 진행 상태와 결제 금액을 확인할 수 있습니다.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.5,
              color: const Color(0xFF5F6C62),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderListItem extends StatelessWidget {
  const _OrderListItem({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final firstItem = order.items.first;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE3DD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.orderDetail,
          arguments: order.orderId,
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 720;
              final content = Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const _OrderThumb(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.orderNumber,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          order.items.length > 1
                              ? '${firstItem.productName} 외 ${order.items.length - 1}건'
                              : firstItem.productName,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: const Color(0xFF5F6C62)),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            StatusBadge(label: order.orderStatusLabel),
                            StatusBadge(label: formatPrice(order.totalAmount)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final arrow = Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.primary,
              );

              if (!isWide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [content, const SizedBox(height: 12), arrow],
                );
              }

              return Row(
                children: [
                  Expanded(child: content),
                  arrow,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OrderThumb extends StatelessWidget {
  const _OrderThumb();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFE7F3EB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.receipt_long_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
