import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/repositories/return_repository.dart';
import '../../view_models/my_returns_view_model.dart';
import '../../widgets/brand_app_bar_title.dart';
import '../../widgets/empty_state_panel.dart';
import '../../widgets/status_badge.dart';

class MyReturnsPage extends StatefulWidget {
  const MyReturnsPage({super.key});

  @override
  State<MyReturnsPage> createState() => _MyReturnsPageState();
}

class _MyReturnsPageState extends State<MyReturnsPage> {
  late final MyReturnsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MyReturnsViewModel()..load();
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
                      child: _ReturnList(viewModel: _viewModel),
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

class _ReturnList extends StatelessWidget {
  const _ReturnList({required this.viewModel});

  final MyReturnsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (viewModel.errorMessage != null) {
      return EmptyStatePanel(
        icon: Icons.error_outline,
        title: '반품 내역을 불러오지 못했습니다',
        message: viewModel.errorMessage!,
        actionLabel: '다시 시도',
        onAction: viewModel.load,
      );
    }

    if (viewModel.returns.isEmpty) {
      return EmptyStatePanel(
        icon: Icons.assignment_return_outlined,
        title: '접수된 반품 내역이 없습니다',
        message: '배송 완료 후 반품을 신청하면 이곳에서 접수 상태와 환불 진행 상황을 확인할 수 있습니다.',
        actionLabel: '주문 내역 보기',
        onAction: () => Navigator.pushNamed(context, AppRoutes.myOrders),
      );
    }

    return Column(
      children: [
        for (final item in viewModel.returns) ...[
          _ReturnListItem(item: item),
          const SizedBox(height: 12),
        ],
      ],
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
            '반품 상태 확인',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '내 반품 내역',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF163B2B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '접수한 반품 요청의 상태와 요청 금액을 확인할 수 있습니다.',
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

class _ReturnListItem extends StatelessWidget {
  const _ReturnListItem({required this.item});

  final ReturnHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final requestedAtLabel = _dateTimeLabel(item.requestedAt, '접수일 확인 중');
    final decidedAtLabel = _dateTimeLabel(item.decidedAt, '');

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
          arguments: item.orderId,
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const _ReturnThumb(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.returnNumber.isEmpty ? '반품 요청' : item.returnNumber,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.orderNumber.isEmpty ? '주문번호 확인 중' : item.orderNumber,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5F6C62),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        StatusBadge(label: item.returnStatusLabel),
                        StatusBadge(label: item.reasonLabel),
                        StatusBadge(label: formatPrice(item.requestedAmount)),
                        StatusBadge(label: requestedAtLabel),
                        if (item.approvedAmount > 0)
                          StatusBadge(
                            label: '승인 ${formatPrice(item.approvedAmount)}',
                          ),
                        if (decidedAtLabel.isNotEmpty)
                          StatusBadge(label: decidedAtLabel),
                      ],
                    ),
                    if (item.reasonDetail.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        item.reasonDetail,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF4B584D),
                        ),
                      ),
                    ],
                    if (item.decisionReason.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        item.decisionReason,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF4B584D),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dateTimeLabel(DateTime? value, String fallback) {
    if (value == null) {
      return fallback;
    }
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$month.$day $hour:$minute';
  }
}

class _ReturnThumb extends StatelessWidget {
  const _ReturnThumb();

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
        Icons.assignment_return_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
