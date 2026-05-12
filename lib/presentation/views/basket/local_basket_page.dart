import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/session/mock_auth_session.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/local_basket_item_model.dart';
import '../../../demo/customer_coach_tour_manager.dart';
import '../../../demo/customer_demo_target_keys.dart';
import '../../view_models/local_basket_view_model.dart';
import '../../widgets/app_alert_dialog.dart';
import '../../widgets/brand_app_bar_title.dart';
import '../../widgets/flow_status_badge.dart';
import '../../widgets/notice_box.dart';
import '../../widgets/status_badge.dart';

class LocalBasketPage extends StatefulWidget {
  const LocalBasketPage({super.key});

  @override
  State<LocalBasketPage> createState() => _LocalBasketPageState();
}

class _LocalBasketPageState extends State<LocalBasketPage> {
  late final LocalBasketViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = LocalBasketViewModel()..load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CustomerCoachTourManager.instance.onPageReady(
        CustomerCoachTourStage.basket,
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
        actions: [
          const FlowStatusBadge(
            stepLabel: '예약 흐름 1/5',
            statusLabel: '담아둔 상품',
            icon: Icons.shopping_basket_outlined,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.products),
              icon: const Icon(Icons.add),
              label: const Text('상품 더 보기'),
            ),
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
                          final list = _BasketList(
                            items: _viewModel.items,
                            onIncrease: _viewModel.increasePackageCount,
                            onDecrease: _viewModel.decreasePackageCount,
                            onSelect: _viewModel.toggleItemSelection,
                            isSelected: _viewModel.isSelected,
                            onRemoveSelected: _viewModel.removeSelectedItems,
                            hasSelectedItems: _viewModel.hasSelectedItems,
                          );
                          final summary = _BasketSummary(viewModel: _viewModel);

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

  final LocalBasketViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '주문 전 확인',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '담아둔 수확 상품을 확인하세요',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF163B2B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '수확 예정일과 박스 수량을 확인한 뒤 예약을 진행하세요. 주문 전까지 언제든 상품을 빼거나 더 담을 수 있습니다.',
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
              StatusBadge(label: '${viewModel.items.length}개 상품'),
              StatusBadge(label: '총 ${formatKg(viewModel.totalReservedKg)}kg'),
            ],
          ),
        ],
      ),
    );
  }
}

class _BasketList extends StatelessWidget {
  const _BasketList({
    required this.items,
    required this.onIncrease,
    required this.onDecrease,
    required this.onSelect,
    required this.isSelected,
    required this.onRemoveSelected,
    required this.hasSelectedItems,
  });

  final List<LocalBasketItemModel> items;
  final ValueChanged<LocalBasketItemModel> onIncrease;
  final ValueChanged<LocalBasketItemModel> onDecrease;
  final void Function(LocalBasketItemModel item, bool selected) onSelect;
  final bool Function(LocalBasketItemModel item) isSelected;
  final VoidCallback onRemoveSelected;
  final bool hasSelectedItems;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyBasketPanel();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BasketSelectionToolbar(
          selectedCount: items.where(isSelected).length,
          onRemoveSelected: hasSelectedItems ? onRemoveSelected : null,
        ),
        const SizedBox(height: 12),
        for (final item in items) ...[
          _BasketItemCard(
            item: item,
            selected: isSelected(item),
            onSelected: (selected) => onSelect(item, selected),
            onIncrease: () => onIncrease(item),
            onDecrease: () => onDecrease(item),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _BasketItemCard extends StatelessWidget {
  const _BasketItemCard({
    required this.item,
    required this.selected,
    required this.onSelected,
    required this.onIncrease,
    required this.onDecrease,
  });

  final LocalBasketItemModel item;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: selected,
                  onChanged: (value) => onSelected(value ?? false),
                ),
                const SizedBox(width: 4),
                const _BasketThumb(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.farmName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF657166),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [const StatusBadge(label: '주문 전')],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  label: '${item.harvestStartLabel}-${item.harvestEndLabel}',
                ),
                _InfoChip(label: '${item.packageCount}박스'),
                _InfoChip(label: '${formatKg(item.reservedKg)}kg'),
              ],
            ),
            const SizedBox(height: 14),
            _QuantityStepper(
              packageCount: item.packageCount,
              onIncrease: onIncrease,
              onDecrease: item.packageCount > 1 ? onDecrease : null,
            ),
            const SizedBox(height: 14),
            _ItemRow(
              label: '박스 단위',
              value: '${formatKg(item.packageUnitKg)}kg',
            ),
            const SizedBox(height: 8),
            _ItemRow(label: '금액', value: formatPrice(item.subtotalAmount)),
          ],
        ),
      ),
    );
  }
}

class _EmptyBasketPanel extends StatelessWidget {
  const _EmptyBasketPanel();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE3DD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.shopping_basket_outlined,
              size: 42,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              '담아둔 상품이 없습니다',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              '수확 예정 사과를 선택해 먼저 담아보세요.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF5F6C62)),
            ),
          ],
        ),
      ),
    );
  }
}

class _BasketSelectionToolbar extends StatelessWidget {
  const _BasketSelectionToolbar({
    required this.selectedCount,
    required this.onRemoveSelected,
  });

  final int selectedCount;
  final VoidCallback? onRemoveSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE3DD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedCount == 0
                    ? '삭제할 상품을 선택할 수 있습니다'
                    : '$selectedCount개 상품 선택됨',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5F6C62),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: onRemoveSelected,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('선택 삭제'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.packageCount,
    required this.onIncrease,
    required this.onDecrease,
  });

  final int packageCount;
  final VoidCallback onIncrease;
  final VoidCallback? onDecrease;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '박스 수량',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF5F6C62),
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        IconButton.outlined(
          onPressed: onDecrease,
          icon: const Icon(Icons.remove),
          tooltip: '수량 줄이기',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '$packageCount',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        IconButton.filled(
          onPressed: onIncrease,
          icon: const Icon(Icons.add),
          tooltip: '수량 늘리기',
        ),
      ],
    );
  }
}

class _BasketThumb extends StatelessWidget {
  const _BasketThumb();

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
        Icons.inventory_2_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _BasketSummary extends StatelessWidget {
  const _BasketSummary({required this.viewModel});

  final LocalBasketViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '예상 주문 금액',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            _ItemRow(label: '담은 상품', value: '${viewModel.items.length}개'),
            const SizedBox(height: 10),
            _ItemRow(
              label: '총 예약 중량',
              value: '${formatKg(viewModel.totalReservedKg)}kg',
            ),
            const SizedBox(height: 10),
            _ItemRow(label: '예상 금액', value: formatPrice(viewModel.totalAmount)),
            const SizedBox(height: 18),
            const NoticeBox(
              message: '예약을 진행하면 농가가 확정한 수확 가능 수량과 금액을 다시 확인합니다.',
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              key: CustomerDemoTargetKeys.basketPrimaryAction,
              onPressed: viewModel.items.isEmpty
                  ? null
                  : () async {
                      if (!MockAuthSession.isLoggedIn) {
                        await showAppAlertDialog(
                          context,
                          message:
                              '예약은 로그인 후 진행할 수 있습니다. 로그인 화면으로 이동합니다.',
                        );
                        if (!context.mounted) return;
                        Navigator.pushNamed(context, AppRoutes.login);
                        return;
                      }

                      Navigator.pushNamed(
                        context,
                        AppRoutes.reservationConfirm,
                      );
                    },
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('예약 진행하기'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4EE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: const Color(0xFF4B584D),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.label, required this.value});

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
