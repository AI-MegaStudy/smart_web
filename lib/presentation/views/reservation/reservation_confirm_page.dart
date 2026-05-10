import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/local_basket_item_model.dart';
import '../../view_models/reservation_confirm_view_model.dart';
import '../../widgets/app_alert_dialog.dart';
import '../../widgets/brand_app_bar_title.dart';
import '../../widgets/empty_state_panel.dart';
import '../../widgets/flow_status_badge.dart';
import '../../widgets/notice_box.dart';
import '../../widgets/status_badge.dart';

class ReservationConfirmPage extends StatefulWidget {
  const ReservationConfirmPage({super.key});

  @override
  State<ReservationConfirmPage> createState() => _ReservationConfirmPageState();
}

class _ReservationConfirmPageState extends State<ReservationConfirmPage> {
  late final ReservationConfirmViewModel _viewModel;
  bool _hasShownAvailabilityAlert = false;

  @override
  void initState() {
    super.initState();
    _viewModel = ReservationConfirmViewModel()..load();
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
            stepLabel: '예약 흐름 2/5',
            statusLabel: '예약 확인',
            icon: Icons.fact_check_outlined,
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

            if (_viewModel.items.isEmpty) {
              return Center(
                child: _ConstrainedContent(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: EmptyStatePanel(
                      icon: Icons.shopping_basket_outlined,
                      title: '확인할 예약 상품이 없습니다',
                      message: '예약함에 수확 상품을 담은 뒤 주문 전 확인을 진행할 수 있습니다.',
                      actionLabel: '상품 보러가기',
                      onAction: () =>
                          Navigator.pushNamed(context, AppRoutes.products),
                    ),
                  ),
                ),
              );
            }

            if (_viewModel.hasBlockingIssue && !_hasShownAvailabilityAlert) {
              _hasShownAvailabilityAlert = true;
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (!mounted) {
                  return;
                }

                await showAppAlertDialog(
                  context,
                  message: '현재 예약 가능한 수량이 변경되었습니다. 예약 내용을 확인한 뒤 다시 진행해주세요.',
                );
              });
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _ConstrainedContent(
                    child: _PageIntro(viewModel: _viewModel),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _ConstrainedContent(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 980;
                          final list = _ReservationItemList(
                            items: _viewModel.items,
                            issueForItem: _viewModel.issueForItem,
                          );
                          final summary = _ReservationSummary(
                            viewModel: _viewModel,
                          );

                          if (!isWide) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                list,
                                const SizedBox(height: 18),
                                summary,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 6, child: list),
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
  const _PageIntro({required this.viewModel});

  final ReservationConfirmViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '주문 전 마지막 확인',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '담아둔 수확 상품을 한 번 더 확인하세요',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF163B2B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '수확 예정일, 박스 수량, 결제 예정 금액을 확인한 뒤 주문서 작성으로 이동하세요.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.5,
              color: const Color(0xFF5F6C62),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              const StatusBadge(label: '주문 전 확인'),
              StatusBadge(label: '${viewModel.items.length}개 상품'),
              StatusBadge(label: '총 ${formatKg(viewModel.totalReservedKg)}kg'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReservationItemList extends StatelessWidget {
  const _ReservationItemList({required this.items, required this.issueForItem});

  final List<LocalBasketItemModel> items;
  final String? Function(LocalBasketItemModel item) issueForItem;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in items) ...[
          _ReservationItemCard(item: item, issueMessage: issueForItem(item)),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ReservationItemCard extends StatelessWidget {
  const _ReservationItemCard({required this.item, required this.issueMessage});

  final LocalBasketItemModel item;
  final String? issueMessage;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE3DD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.productName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                StatusBadge(label: issueMessage == null ? '확인 중' : '재확인 필요'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.farmName,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF657166)),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: '수확 예정 범위',
              value: '${item.harvestStartLabel}-${item.harvestEndLabel}',
            ),
            const SizedBox(height: 10),
            _InfoRow(
              label: '포장 단위',
              value: '${formatKg(item.packageUnitKg)}kg 박스',
            ),
            const SizedBox(height: 10),
            _InfoRow(label: '박스 수량', value: '${item.packageCount}박스'),
            const SizedBox(height: 10),
            _InfoRow(label: '총 수량', value: '${formatKg(item.reservedKg)}kg'),
            const SizedBox(height: 10),
            _InfoRow(label: '금액', value: formatPrice(item.subtotalAmount)),
            const SizedBox(height: 12),
            const NoticeBox(
              message: '주문서 작성 전 수확 가능 수량과 금액을 한 번 더 확인합니다.',
              icon: Icons.verified_outlined,
            ),
            if (issueMessage != null) ...[
              const SizedBox(height: 12),
              NoticeBox(
                message: issueMessage!,
                icon: Icons.error_outline,
                backgroundColor: const Color(0xFFFFF1ED),
                borderColor: const Color(0xFFF3C5B8),
                iconColor: const Color(0xFFBE3A20),
                textColor: const Color(0xFF7A2516),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReservationSummary extends StatelessWidget {
  const _ReservationSummary({required this.viewModel});

  final ReservationConfirmViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE3DD)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '예약 상품 확인',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF163B2B),
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(label: '담은 상품', value: '${viewModel.items.length}개'),
            const SizedBox(height: 10),
            _InfoRow(
              label: '총 수량',
              value: '${formatKg(viewModel.totalReservedKg)}kg',
            ),
            const SizedBox(height: 10),
            _InfoRow(
              label: '결제 예정 금액',
              value: formatPrice(viewModel.totalAmount),
            ),
            const SizedBox(height: 18),
            const _ReservationGuideBox(
              title: '수확 일정 안내',
              message: '농가가 정한 수확 예정 기간입니다. 기상과 생육 상황에 따라 일정이 조정될 수 있습니다.',
              icon: Icons.event_available_outlined,
              backgroundColor: Color(0xFFFFF6E0),
              borderColor: Color(0xFFEED8A8),
              iconColor: Color(0xFF9A6A16),
              textColor: Color(0xFF5D4312),
            ),
            const SizedBox(height: 12),
            const _ReservationGuideBox(
              title: '다음 단계 안내',
              message: '배송 정보를 입력하고 결제 전 금액을 다시 확인합니다.',
              icon: Icons.verified_outlined,
              backgroundColor: Color(0xFFEFF7F1),
              borderColor: Color(0xFFCFE2D5),
              iconColor: Color(0xFF2F6B4E),
              textColor: Color(0xFF214634),
            ),
            if (viewModel.hasBlockingIssue) ...[
              const SizedBox(height: 12),
              const NoticeBox(
                message:
                    '예약 가능한 수량이 바뀐 항목이 있어 주문서 작성으로 바로 넘어갈 수 없습니다. 예약함에서 수량을 다시 확인해주세요.',
                icon: Icons.error_outline,
                backgroundColor: Color(0xFFFFF1ED),
                borderColor: Color(0xFFF3C5B8),
                iconColor: Color(0xFFBE3A20),
                textColor: Color(0xFF7A2516),
              ),
            ],
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: viewModel.hasBlockingIssue || viewModel.isSubmitting
                  ? null
                  : () async {
                      final reservationId = await viewModel.createReservation();
                      if (!context.mounted) return;

                      if (reservationId == null) {
                        await showAppAlertDialog(
                          context,
                          message:
                              viewModel.previewErrorMessage ??
                              '예약을 완료하지 못했습니다. 예약 내용을 다시 확인해주세요.',
                        );
                        return;
                      }

                      Navigator.pushNamed(
                        context,
                        AppRoutes.checkout,
                        arguments: reservationId,
                      );
                    },
              icon: Icon(
                viewModel.isSubmitting
                    ? Icons.hourglass_empty
                    : Icons.check_circle_outline,
              ),
              label: const Text('주문서 작성하기'),
            ),
            if (viewModel.hasBlockingIssue) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.basket),
                icon: const Icon(Icons.shopping_basket_outlined),
                label: const Text('예약함으로 돌아가기'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReservationGuideBox extends StatelessWidget {
  const _ReservationGuideBox({
    required this.title,
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textColor,
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

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
