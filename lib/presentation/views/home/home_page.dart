import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../view_models/home_view_model.dart';
import '../../widgets/notice_box.dart';
import '../../widgets/product_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel()..load();
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
        toolbarHeight: 72,
        titleSpacing: 16,
        title: const SizedBox(height: 72, child: _HomeTopBar()),
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
                    child: _HeroSection(
                      onProductsTap: () =>
                          Navigator.pushNamed(context, AppRoutes.products),
                      onFeaturedTap: () =>
                          Navigator.pushNamed(context, AppRoutes.products),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _ConstrainedContent(
                    child: _SectionHeader(
                      title: '이번 주 오픈 수확 슬롯',
                      label: '예약 가능한 상품',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.products),
                    ),
                  ),
                ),
                if (_viewModel.isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: _ConstrainedContent(
                      child: LayoutBuilder(
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
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            itemCount: _viewModel.featuredProducts.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columnCount,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: columnCount == 1
                                      ? 0.72
                                      : 0.78,
                                ),
                            itemBuilder: (context, index) {
                              final product =
                                  _viewModel.featuredProducts[index];
                              return ProductCard(
                                product: product,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.products,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: _ConstrainedContent(child: const _GuideSection()),
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

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.onProductsTap,
    required this.onFeaturedTap,
  });

  final VoidCallback onProductsTap;
  final VoidCallback onFeaturedTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          final copy = Padding(
            padding: EdgeInsets.fromLTRB(
              isWide ? 34 : 18,
              isWide ? 42 : 28,
              isWide ? 24 : 18,
              isWide ? 42 : 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _Label(
                  icon: Icons.event_available,
                  text: '농가 확정 수확 슬롯 예약',
                ),
                const SizedBox(height: 10),
                Text(
                  '수확일이 확정된 사과만 예약하세요',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.08,
                    color: const Color(0xFF163B2B),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '농가가 직접 확정한 수확 예정 범위와 예약 가능 수량을 기준으로 주문하고 배송 상태까지 확인합니다.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.62,
                    color: const Color(0xFF56645B),
                  ),
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: onProductsTap,
                      icon: const Icon(Icons.inventory_2_outlined),
                      label: const Text('예약 상품 보기'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onFeaturedTap,
                      icon: const Icon(Icons.spa_outlined),
                      label: const Text('대표 상품'),
                    ),
                  ],
                ),
              ],
            ),
          );

          final image = Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                'https://images.unsplash.com/photo-1570913149827-d2ac84ab3f9a?auto=format&fit=crop&w=1300&q=80',
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
              Positioned(
                left: isWide ? null : 16,
                right: isWide ? 18 : null,
                bottom: 18,
                child: Container(
                  width: 185,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xDD163B2B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '10.12-10.18',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '충주 햇살농원 후지 사과 수확 예정',
                        style: TextStyle(
                          color: Color(0xCCFFFFFF),
                          fontSize: 12,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );

          if (!isWide) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF8F4DF), Color(0xFFE7F3EB)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 205, child: image),
                    copy,
                  ],
                ),
              ),
            );
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF8F4DF), Color(0xFFE7F3EB)],
                ),
              ),
              child: SizedBox(
                height: 360,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 105, child: copy),
                    Expanded(flex: 95, child: image),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.label,
    required this.onTap,
  });

  final String title;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('전체 보기'),
          ),
        ],
      ),
    );
  }
}

class _GuideSection extends StatelessWidget {
  const _GuideSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          const children = [
            _GuideCard(
              icon: Icons.verified_outlined,
              title: '농가 확정 기준',
              description: '고객에게는 점주가 확정한 수확 범위와 예약 가능 수량만 보여줍니다.',
            ),
            _GuideCard(
              icon: Icons.local_shipping_outlined,
              title: '수확 직배송',
              description: '결제 후 농가 확인, 선별, 배송 상태를 주문 상세에서 확인합니다.',
            ),
            NoticeBox(
              message: '농가가 확정한 수확 예정 범위입니다.\n기상과 생육 상황에 따라 일정이 조정될 수 있습니다.',
            ),
          ];

          if (!isWide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final child in children) ...[
                  child,
                  const SizedBox(height: 14),
                ],
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < children.length; index += 1) ...[
                Expanded(child: children[index]),
                if (index != children.length - 1) const SizedBox(width: 14),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 14),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.45,
                color: const Color(0xFF5F6C62),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;
        final brandWidth = isCompact ? 180.0 : 260.0;
        return Row(
          children: [
            SizedBox(
              width: brandWidth,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (route) => false,
                ),
                child: Row(
                  children: [
                    Container(
                      width: isCompact ? 34 : 36,
                      height: isCompact ? 34 : 36,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.eco,
                        color: Colors.white,
                        size: isCompact ? 19 : 21,
                      ),
                    ),
                    SizedBox(width: isCompact ? 8 : 12),
                    Expanded(
                      child: Text(
                        'Harvest Slot',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isCompact ? 17 : 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _TopAction(
                        label: '상품',
                        routeName: AppRoutes.products,
                        compact: isCompact,
                      ),
                      _TopAction(
                        label: '내 주문',
                        routeName: AppRoutes.myOrders,
                        compact: isCompact,
                      ),
                      _TopAction(
                        label: '회원가입',
                        routeName: AppRoutes.signup,
                        compact: isCompact,
                      ),
                      _TopAction(
                        label: '로그인',
                        routeName: AppRoutes.login,
                        compact: isCompact,
                      ),
                      SizedBox(width: isCompact ? 4 : 8),
                      _BasketAction(compact: isCompact),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TopAction extends StatelessWidget {
  const _TopAction({
    required this.label,
    required this.routeName,
    required this.compact,
  });

  final String label;
  final String routeName;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, routeName),
      style: TextButton.styleFrom(
        minimumSize: Size(compact ? 48 : 64, 40),
        padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 14),
      ),
      child: Text(
        label,
        maxLines: 1,
        style: TextStyle(
          fontSize: compact ? 13 : 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BasketAction extends StatelessWidget {
  const _BasketAction({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: () => Navigator.pushNamed(context, AppRoutes.basket),
      icon: Icon(Icons.shopping_basket_outlined, size: compact ? 20 : 22),
      tooltip: '예약함',
      constraints: BoxConstraints.tightFor(
        width: compact ? 42 : 48,
        height: compact ? 42 : 48,
      ),
    );
  }
}
