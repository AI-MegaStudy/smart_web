import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../demo/customer_coach_tour_manager.dart';
import '../../../demo/customer_demo_target_keys.dart';
import '../../view_models/product_list_view_model.dart';
import '../../widgets/empty_state_panel.dart';
import '../../widgets/notice_box.dart';
import '../../widgets/product_card.dart';
import '../../widgets/status_badge.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late final ProductListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProductListViewModel()..load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CustomerCoachTourManager.instance.onPageReady(
        CustomerCoachTourStage.productList,
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
        titleSpacing: 20,
        title: const _BrandHomeLink(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton.filled(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.basket),
              icon: const Icon(Icons.shopping_basket_outlined),
              tooltip: '예약함',
            ),
          ),
        ],
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
        child: AnimatedBuilder(
          animation: _viewModel,
          builder: (context, _) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _ConstrainedContent(
                    child: _PageIntro(viewModel: _viewModel),
                  ),
                ),
                if (_viewModel.isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: _ConstrainedContent(
                      child: _FilterBar(viewModel: _viewModel),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _ConstrainedContent(
                      child: _ProductGrid(viewModel: _viewModel),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.viewModel});

  final ProductListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final products = viewModel.filteredProducts;

    if (viewModel.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        child: EmptyStatePanel(
          icon: Icons.error_outline,
          title: '상품을 불러오지 못했습니다',
          message: viewModel.errorMessage!,
          actionLabel: '다시 시도',
          onAction: viewModel.load,
        ),
      );
    }

    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        child: EmptyStatePanel(
          icon: Icons.inventory_2_outlined,
          title: '예약 가능한 상품이 없습니다',
          message: '선택한 조건에 맞는 수확 상품이 없습니다. 다른 품종을 선택하거나 잠시 후 다시 확인해주세요.',
          actionLabel: '전체 상품 보기',
          onAction: () => viewModel.selectVariety(viewModel.varieties.first),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columnCount = width >= 960
            ? 3
            : width >= 640
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            columnCount == 1 ? 16 : 24,
            0,
            columnCount == 1 ? 16 : 24,
            columnCount == 1 ? 28 : 40,
          ),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: columnCount == 1 ? 1.16 : 1.02,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              key: index == 0 ? CustomerDemoTargetKeys.productListFirstCard : null,
              product: product,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.productDetail,
                arguments: product.productId,
              ),
            );
          },
        );
      },
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

class _BrandHomeLink extends StatelessWidget {
  const _BrandHomeLink();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      ),
      child: Container(
        width: 260,
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F1ED),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.eco, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Harvest Slot',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageIntro extends StatelessWidget {
  const _PageIntro({required this.viewModel});

  final ProductListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            isWide ? 24 : 16,
            isWide ? 24 : 16,
            isWide ? 24 : 16,
            isWide ? 18 : 12,
          ),
          child: Builder(
            builder: (context) {
              final title = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Eyebrow(text: '수확 예정 사과'),
                  const SizedBox(height: 8),
                  Text(
                    '햇살을 머금은 사과를 수확 일정에 맞춰 예약하세요',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF163B2B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '농가가 확정한 수확 예정 기간과 포장 단위를 확인하고, 가장 신선한 시기에 받아보세요.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                      color: const Color(0xFF5F6C62),
                    ),
                  ),
                ],
              );

              final summary = _SummaryPanel(viewModel: viewModel);

              if (!isWide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [title, const SizedBox(height: 18), summary],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: title),
                  const SizedBox(width: 18),
                  Expanded(flex: 3, child: summary),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({required this.viewModel});

  final ProductListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoading) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StatusBadge(label: '이번 수확 한눈에 보기'),
            const SizedBox(height: 16),
            _SummaryRow(
              label: '예약 가능한 사과',
              value: '${viewModel.openSlotCount}종',
            ),
            const SizedBox(height: 10),
            _SummaryRow(
              label: '다음 수확 준비 중',
              value: '${viewModel.preparingCount}종',
            ),
            const SizedBox(height: 10),
            _SummaryRow(
              label: '곧 마감될 수 있어요',
              value: '${viewModel.lowStockCount}종',
            ),
          ],
        ),
      ),
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

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.viewModel});

  final ProductListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final variety in viewModel.varieties)
                ChoiceChip(
                  label: Text(variety),
                  selected: viewModel.selectedVariety == variety,
                  onSelected: (_) => viewModel.selectVariety(variety),
                ),
            ],
          ),
          const SizedBox(height: 10),
          const NoticeBox(
            message: '농가가 확정한 수확 예정 범위입니다. 기상과 생육 상황에 따라 일정이 조정될 수 있습니다.',
          ),
        ],
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
