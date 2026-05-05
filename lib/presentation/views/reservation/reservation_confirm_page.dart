import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/local_basket_item_model.dart';
import '../../view_models/reservation_confirm_view_model.dart';
import '../../widgets/brand_app_bar_title.dart';
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
  const _ReservationItemList({required this.items});

  final List<LocalBasketItemModel> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in items) ...[
          _ReservationItemCard(item: item),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ReservationItemCard extends StatelessWidget {
  const _ReservationItemCard({required this.item});

  final LocalBasketItemModel item;

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
                const StatusBadge(label: '확인 중'),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '예약 내용 요약',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
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
            const NoticeBox(
              message: '농가가 정한 수확 예정 기간입니다. 기상과 생육 상황에 따라 일정이 조정될 수 있습니다.',
            ),
            const SizedBox(height: 12),
            const NoticeBox(
              message: '다음 단계에서 배송 정보를 입력하고 결제 전 금액을 다시 확인합니다.',
              icon: Icons.verified_outlined,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.checkout,
                arguments: 5,
              ),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('주문서 작성하기'),
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
