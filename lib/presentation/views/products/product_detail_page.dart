import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/router.dart';
import '../../../core/session/mock_auth_session.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/product_model.dart';
import '../../view_models/product_detail_view_model.dart';
import '../../widgets/app_alert_dialog.dart';
import '../../widgets/brand_app_bar_title.dart';
import '../../widgets/harvest_slot_card.dart';
import '../../widgets/notice_box.dart';
import '../../widgets/price_text.dart';
import '../../widgets/status_badge.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.productId});

  final int productId;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late final ProductDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProductDetailViewModel(productId: widget.productId)..load();
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
            final product = _viewModel.product;
            if (_viewModel.isLoading || product == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _ConstrainedContent(
                    child: product.isReservable
                        ? _DetailHero(viewModel: _viewModel, product: product)
                        : _PreparingDetailHero(product: product),
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

class _PreparingDetailHero extends StatelessWidget {
  const _PreparingDetailHero({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final image = ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: isWide ? 0.95 : 1.7,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFE3E9DF),
                    child: const Center(
                      child: Icon(Icons.image_not_supported_outlined, size: 48),
                    ),
                  );
                },
              ),
            ),
          );

          final info = DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFDCE3DD)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StatusBadge(label: '다음 수확 준비중'),
                  const SizedBox(height: 14),
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF163B2B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${product.farmName} · ${product.name}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF5F6C62),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const NoticeBox(
                    message: '농가가 다음 수확 일정과 예약 가능 수량을 확정하면 이 상품을 예약할 수 있습니다.',
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '현재는 예약함에 담을 수 없어요. 예약 가능한 다른 수확 상품을 먼저 확인해보세요.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: const Color(0xFF5F6C62),
                    ),
                  ),
                  const SizedBox(height: 22),
                  OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.products),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('다른 예약 상품 보기'),
                  ),
                ],
              ),
            ),
          );

          if (!isWide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [image, const SizedBox(height: 18), info],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 95, child: image),
              const SizedBox(width: 20),
              Expanded(flex: 105, child: info),
            ],
          );
        },
      ),
    );
  }
}

class _DetailHero extends StatelessWidget {
  const _DetailHero({required this.viewModel, required this.product});

  final ProductDetailViewModel viewModel;
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final image = ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: isWide ? 0.95 : 1.7,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFE3E9DF),
                    child: const Center(
                      child: Icon(Icons.image_not_supported_outlined, size: 48),
                    ),
                  );
                },
              ),
            ),
          );

          final productStory = _ProductStoryPanel(product: product);

          final info = DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFDCE3DD)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StatusBadge(label: '수확 슬롯 예약'),
                  const SizedBox(height: 12),
                  Text(
                    '${product.name} 예약',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF163B2B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${product.farmName} · ${product.name}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF5F6C62),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '패키지 단위 선택',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _PackageChoiceGrid(viewModel: viewModel),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      PriceText(price: viewModel.selectedPackagePrice),
                      const SizedBox(width: 6),
                      Text(
                        '/ 선택 패키지',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF5F6C62),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    '수확 슬롯 선택',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final slot in viewModel.slots) ...[
                    HarvestSlotCard(
                      slot: slot,
                      packageUnitKg: viewModel.selectedPackageUnitKg,
                      packagePrice: viewModel.packagePriceForSlot(slot),
                      availablePackageCount: viewModel
                          .availablePackageCountForSlot(slot),
                      selected: viewModel.selectedSlot?.slotId == slot.slotId,
                      onTap: () => viewModel.selectSlot(slot),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '박스 수량 선택',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _PackageCountSelector(viewModel: viewModel),
                  const SizedBox(height: 14),
                  _SelectedReservationSummary(viewModel: viewModel),
                  const SizedBox(height: 14),
                  const NoticeBox(
                    message:
                        '이 상품은 농가가 확정한 수확 예정 범위 안에서 예약 판매됩니다. 수확 일정은 기상과 생육 상황에 따라 조정될 수 있습니다.',
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () async {
                      if (!MockAuthSession.isLoggedIn) {
                        await showAppAlertDialog(
                          context,
                          message: '예약은 로그인 후 진행할 수 있습니다. 로그인 화면으로 이동합니다.',
                        );
                        if (!context.mounted) return;
                        Navigator.pushNamed(context, AppRoutes.login);
                        return;
                      }

                      final saved = viewModel.addSelectedReservationToBasket();
                      if (!saved) {
                        showAppAlertDialog(
                          context,
                          message: '예약할 상품과 수확 일정을 먼저 선택해주세요.',
                        );
                        return;
                      }

                      if (!context.mounted) return;
                      final goToBasket = await showDialog<bool>(
                        context: context,
                        builder: (context) => const _BasketAddedDialog(),
                      );
                      if (!context.mounted || goToBasket != true) return;
                      Navigator.pushNamed(context, AppRoutes.basket);
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('예약함에 담기'),
                  ),
                ],
              ),
            ),
          );

          if (!isWide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                image,
                const SizedBox(height: 14),
                productStory,
                const SizedBox(height: 18),
                info,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 95,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [image, const SizedBox(height: 14), productStory],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(flex: 105, child: info),
            ],
          );
        },
      ),
    );
  }
}

class _BasketAddedDialog extends StatelessWidget {
  const _BasketAddedDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('예약함에 담았습니다'),
      content: const Text(
        '선택한 수확 상품을 예약함에 담았습니다. 계속 둘러보거나 예약함에서 내용을 확인할 수 있어요.',
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('계속 둘러보기'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.shopping_basket_outlined),
          label: const Text('예약함 보기'),
        ),
      ],
    );
  }
}

class _ProductStoryPanel extends StatelessWidget {
  const _ProductStoryPanel({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE3DD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${product.farmName} ${product.name}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF163B2B),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '농가가 확정한 수확 예정 기간에 맞춰 예약을 받고, 수확 후 선별하여 순차 배송합니다.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.55,
                color: const Color(0xFF5F6C62),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _InfoTile(
                  icon: Icons.event_available_outlined,
                  title: '수확 예정',
                  value:
                      '${product.harvestStartLabel}-${product.harvestEndLabel}',
                ),
                const _InfoTile(
                  icon: Icons.local_shipping_outlined,
                  title: '배송 안내',
                  value: '수확 후 선별 직배송',
                ),
                const _InfoTile(
                  icon: Icons.verified_outlined,
                  title: '예약 안내',
                  value: '농가 확정 수량 기준',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E6DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: const Color(0xFF5F6C62),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF163B2B),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageChoiceGrid extends StatelessWidget {
  const _PackageChoiceGrid({required this.viewModel});

  final ProductDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    const choices = [
      (1.0, '1kg', '소포장'),
      (3.0, '3kg', '가정용'),
      (5.0, '5kg', '인기'),
      (7.5, '7.5kg', '넉넉한 양'),
      (10.0, '10kg', '대용량'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = constraints.maxWidth >= 520 ? 5 : 3;
        return GridView.count(
          crossAxisCount: columnCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.35,
          children: [
            for (final choice in choices)
              _PackageChoiceCard(
                title: choice.$2,
                subtitle: choice.$3,
                selected: viewModel.selectedPackageUnitKg == choice.$1,
                onTap: () => viewModel.selectPackageUnit(choice.$1),
              ),
          ],
        );
      },
    );
  }
}

class _PackageChoiceCard extends StatelessWidget {
  const _PackageChoiceCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE7F3EB) : Colors.white,
            border: Border.all(
              color: selected
                  ? const Color(0xFF2F6B4E)
                  : const Color(0xFFDCE3DD),
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF163B2B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF5F6C62),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PackageCountSelector extends StatelessWidget {
  const _PackageCountSelector({required this.viewModel});

  final ProductDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton.outlined(
              onPressed: viewModel.canDecrease
                  ? viewModel.decreasePackageCount
                  : null,
              icon: const Icon(Icons.remove),
              tooltip: '수량 줄이기',
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 120,
              child: TextFormField(
                key: ValueKey(viewModel.packageCount),
                initialValue: '${viewModel.packageCount}',
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  suffixText: '박스',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  final count = int.tryParse(value);
                  if (count == null) {
                    return;
                  }

                  if (count > viewModel.maxPackageCount) {
                    showAppAlertDialog(context, message: '준비된 수량을 초과했습니다.');
                  }
                  viewModel.selectPackageCount(count);
                },
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              onPressed: viewModel.canIncrease
                  ? viewModel.increasePackageCount
                  : null,
              icon: const Icon(Icons.add),
              tooltip: '수량 늘리기',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '최대 ${viewModel.maxPackageCount}박스까지 예약할 수 있습니다.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: const Color(0xFF5F6C62)),
        ),
      ],
    );
  }
}

class _SelectedReservationSummary extends StatelessWidget {
  const _SelectedReservationSummary({required this.viewModel});

  final ProductDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final product = viewModel.product;
    final slot = viewModel.selectedSlot;
    if (product == null || slot == null) {
      return const SizedBox.shrink();
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F3),
        border: Border.all(color: const Color(0xFFDCE3DD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '선택한 예약',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              '${viewModel.packageCount}박스, 총 ${formatKg(viewModel.reservedKg)}kg',
            ),
            const SizedBox(height: 4),
            Text(
              '${slot.harvestStartLabel}-${slot.harvestEndLabel} 수확분으로 담깁니다.',
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
