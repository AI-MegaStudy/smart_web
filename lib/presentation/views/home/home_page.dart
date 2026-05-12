import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../app/router.dart';
import '../../../core/session/mock_auth_session.dart';
import '../../../demo/customer_coach_tour_manager.dart';
import '../../../demo/customer_demo_target_keys.dart';
import '../../view_models/home_view_model.dart';
import '../../widgets/app_alert_dialog.dart';
import '../../widgets/notice_box.dart';
import '../../widgets/product_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _topKey = GlobalKey();
  final GlobalKey _productsButtonKey =
      CustomerDemoTargetKeys.homeProductsButton;
  final GlobalKey _featuredButtonKey =
      CustomerDemoTargetKeys.homeFeaturedButton;
  final GlobalKey _quickNavKey = CustomerDemoTargetKeys.homeQuickNav;
  final GlobalKey _productsKey = CustomerDemoTargetKeys.homeProducts;
  final GlobalKey _varietyKey = GlobalKey();
  final GlobalKey _storageKey = GlobalKey();
  final GlobalKey _processKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();
  Timer? _coachTourTapResetTimer;
  int _coachTourTapCount = 0;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel()..load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CustomerCoachTourManager.instance.onPageReady(
        CustomerCoachTourStage.homeProductsCta,
        context,
      );
    });
  }

  @override
  void dispose() {
    _coachTourTapResetTimer?.cancel();
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) {
      return;
    }

    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      alignment: 0.06,
    );
  }

  void _openRepresentativeProduct() {
    final product = _viewModel.representativeProduct;
    if (product == null) {
      Navigator.pushNamed(context, AppRoutes.products);
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.productDetail,
      arguments: product.productId,
    );
  }

  void _handleCoachTourTriggerTap() {
    _coachTourTapCount += 1;
    _coachTourTapResetTimer?.cancel();
    _coachTourTapResetTimer = Timer(const Duration(milliseconds: 900), () {
      _coachTourTapCount = 0;
    });

    if (_coachTourTapCount < 3) {
      return;
    }

    _coachTourTapCount = 0;
    CustomerCoachTourManager.instance.startFromHome(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: 16,
        title: SizedBox(
          height: 72,
          child: const _HomeTopBar(),
        ),
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
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: _ConstrainedContent(
                    key: _topKey,
                    child: _RevealOnLoad(
                      delay: Duration.zero,
                      child: _HeroSection(
                        onCoachTourTriggerTap: _handleCoachTourTriggerTap,
                        productsButtonKey: _productsButtonKey,
                        featuredButtonKey: _featuredButtonKey,
                        onProductsTap: () =>
                            Navigator.pushNamed(context, AppRoutes.products),
                        onFeaturedTap: _openRepresentativeProduct,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _ConstrainedContent(
                    key: _productsKey,
                    child: _RevealOnLoad(
                      delay: const Duration(milliseconds: 140),
                      child: _SectionHeader(
                        title: '이번 달 오픈 수확 슬롯',
                        label: '예약 가능한 상품',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.products),
                      ),
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
                    child: _RevealOnLoad(
                      delay: const Duration(milliseconds: 240),
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
                              padding: EdgeInsets.fromLTRB(
                                columnCount == 1 ? 16 : 24,
                                0,
                                columnCount == 1 ? 16 : 24,
                                columnCount == 1 ? 16 : 24,
                              ),
                              itemCount: _viewModel.featuredProducts.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columnCount,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    childAspectRatio: columnCount == 1
                                        ? 1.16
                                        : 1.02,
                                  ),
                              itemBuilder: (context, index) {
                                final product =
                                    _viewModel.featuredProducts[index];
                                return ProductCard(
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
                        ),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: _RevealOnLoad(
                    delay: const Duration(milliseconds: 360),
                    child: _ConstrainedContent(child: const _GuideSection()),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _RevealOnLoad(
                    delay: const Duration(milliseconds: 420),
                    child: _ConstrainedContent(
                      child: const _ParallaxTrustSection(),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _RevealOnLoad(
                    delay: const Duration(milliseconds: 440),
                    child: _ConstrainedContent(
                      key: _varietyKey,
                      child: const _VarietySection(),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _RevealOnLoad(
                    delay: const Duration(milliseconds: 450),
                    child: _ConstrainedContent(
                      key: _storageKey,
                      child: const _StorageSection(),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _RevealOnLoad(
                    delay: const Duration(milliseconds: 455),
                    child: _ConstrainedContent(child: const _EnjoySection()),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _RevealOnLoad(
                    delay: const Duration(milliseconds: 460),
                    child: _ConstrainedContent(
                      key: _processKey,
                      child: const _ProcessSection(),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _RevealOnLoad(
                    delay: const Duration(milliseconds: 480),
                    child: _ConstrainedContent(
                      key: _faqKey,
                      child: const _FaqSection(),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _RevealOnLoad(
                    delay: const Duration(milliseconds: 500),
                    child: _ConstrainedContent(
                      child: const _CleanSupportFooter(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _HomeQuickNav(
        key: _quickNavKey,
        onTopTap: () => _scrollTo(_topKey),
        onProductsTap: () => _scrollTo(_productsKey),
        onVarietyTap: () => _scrollTo(_varietyKey),
        onStorageTap: () => _scrollTo(_storageKey),
        onProcessTap: () => _scrollTo(_processKey),
        onFaqTap: () => _scrollTo(_faqKey),
      ),
      floatingActionButtonLocation: const _ResponsiveQuickNavLocation(),
    );
  }
}

class _ConstrainedContent extends StatelessWidget {
  const _ConstrainedContent({super.key, required this.child});

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

class _ResponsiveQuickNavLocation extends FloatingActionButtonLocation {
  const _ResponsiveQuickNavLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final scaffoldSize = scaffoldGeometry.scaffoldSize;
    final navSize = scaffoldGeometry.floatingActionButtonSize;
    final isMobile = scaffoldSize.width < 720;

    if (isMobile) {
      final bottomInset = scaffoldGeometry.minInsets.bottom;
      return Offset(
        (scaffoldSize.width - navSize.width) / 2,
        scaffoldSize.height - navSize.height - bottomInset - 16,
      );
    }

    final top = (scaffoldSize.height * 0.42)
        .clamp(96.0, scaffoldSize.height - navSize.height - 24)
        .toDouble();

    return Offset(scaffoldSize.width - navSize.width - 18, top);
  }
}

class _HomeQuickNav extends StatelessWidget {
  const _HomeQuickNav({
    super.key,
    required this.onTopTap,
    required this.onProductsTap,
    required this.onVarietyTap,
    required this.onStorageTap,
    required this.onProcessTap,
    required this.onFaqTap,
  });

  final VoidCallback onTopTap;
  final VoidCallback onProductsTap;
  final VoidCallback onVarietyTap;
  final VoidCallback onStorageTap;
  final VoidCallback onProcessTap;
  final VoidCallback onFaqTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = MediaQuery.sizeOf(context).width < 720;
        final items = [
          _QuickNavItem(icon: Icons.arrow_upward, label: '위로', onTap: onTopTap),
          _QuickNavItem(
            icon: Icons.inventory_2_outlined,
            label: '상품',
            onTap: onProductsTap,
          ),
          _QuickNavItem(icon: Icons.apple, label: '품종', onTap: onVarietyTap),
          _QuickNavItem(
            icon: Icons.ac_unit_outlined,
            label: '보관',
            onTap: onStorageTap,
          ),
          _QuickNavItem(
            icon: Icons.route_outlined,
            label: '흐름',
            onTap: onProcessTap,
          ),
          _QuickNavItem(
            icon: Icons.help_outline,
            label: 'FAQ',
            onTap: onFaqTap,
          ),
        ];

        if (isMobile) {
          return _MobileQuickNav(items: items);
        }

        return _DesktopQuickNav(items: items);
      },
    );
  }
}

class _QuickNavItem {
  const _QuickNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _DesktopQuickNav extends StatelessWidget {
  const _DesktopQuickNav({required this.items});

  final List<_QuickNavItem> items;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < items.length; index += 1) ...[
              _DesktopQuickNavButton(item: items[index]),
              if (index != items.length - 1) const SizedBox(height: 4),
            ],
          ],
        ),
      ),
    );
  }
}

class _DesktopQuickNavButton extends StatelessWidget {
  const _DesktopQuickNavButton({required this.item});

  final _QuickNavItem item;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: item.label,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF163B2B),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileQuickNav extends StatelessWidget {
  const _MobileQuickNav({required this.items});

  final List<_QuickNavItem> items;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in items)
              IconButton(
                onPressed: item.onTap,
                icon: Icon(item.icon, size: 18),
                tooltip: item.label,
                color: Theme.of(context).colorScheme.primary,
                constraints: const BoxConstraints.tightFor(
                  width: 38,
                  height: 38,
                ),
                padding: EdgeInsets.zero,
              ),
          ],
        ),
      ),
    );
  }
}

class _RevealOnLoad extends StatefulWidget {
  const _RevealOnLoad({required this.child, required this.delay});

  final Widget child;
  final Duration delay;

  @override
  State<_RevealOnLoad> createState() => _RevealOnLoadState();
}

class _RevealOnLoadState extends State<_RevealOnLoad> {
  bool _visible = false;
  bool _triggered = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey('home-reveal-${widget.hashCode}'),
      onVisibilityChanged: (info) {
        if (_triggered || info.visibleFraction < 0.18) {
          return;
        }

        _triggered = true;
        _showAfterDelay();
      },
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 560),
        curve: Curves.easeOutCubic,
        offset: _visible ? Offset.zero : const Offset(0, 0.055),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 560),
          curve: Curves.easeOutCubic,
          opacity: _visible ? 1 : 0,
          child: widget.child,
        ),
      ),
    );
  }

  void _showAfterDelay() {
    Future<void>.delayed(widget.delay, () {
      if (!mounted) {
        return;
      }

      setState(() {
        _visible = true;
      });
    });
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.onCoachTourTriggerTap,
    required this.productsButtonKey,
    required this.featuredButtonKey,
    required this.onProductsTap,
    required this.onFeaturedTap,
  });

  final VoidCallback onCoachTourTriggerTap;
  final GlobalKey productsButtonKey;
  final GlobalKey featuredButtonKey;
  final VoidCallback onProductsTap;
  final VoidCallback onFeaturedTap;

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
            isWide ? 12 : 8,
          ),
          child: Builder(
            builder: (context) {
              final copy = Padding(
                padding: EdgeInsets.fromLTRB(
                  isWide ? 34 : 18,
                  isWide ? 42 : 22,
                  isWide ? 24 : 18,
                  isWide ? 42 : 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Label(
                      icon: Icons.event_available,
                      text: '농가 확정 수확 슬롯 예약',
                      onTap: onCoachTourTriggerTap,
                    ),
                    SizedBox(height: isWide ? 10 : 8),
                    Text(
                      '수확일이 확정된 사과만 예약하세요',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            height: 1.08,
                            color: const Color(0xFF163B2B),
                          ),
                    ),
                    SizedBox(height: isWide ? 12 : 8),
                    Text(
                      '농가가 직접 확정한 수확 예정 범위와 예약 가능 수량을 기준으로 주문하고 배송 상태까지 확인합니다.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.62,
                        color: const Color(0xFF56645B),
                      ),
                    ),
                    SizedBox(height: isWide ? 22 : 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          key: productsButtonKey,
                          onPressed: onProductsTap,
                          icon: const Icon(Icons.inventory_2_outlined),
                          label: const Text('예약 상품 보기'),
                        ),
                        OutlinedButton.icon(
                          key: featuredButtonKey,
                          onPressed: onFeaturedTap,
                          icon: const Icon(Icons.spa_outlined),
                          label: const Text('대표 상품'),
                        ),
                      ],
                    ),
                  ],
                ),
              );

              // ignore: unused_local_variable
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
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 48,
                          ),
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
                            '문경 햇살 농장 양광 사과 수확 예정',
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
                        SizedBox(
                          height: 178,
                          child: _HeroImageSlider(isWide: isWide),
                        ),
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
                        Expanded(
                          flex: 95,
                          child: _HeroImageSlider(isWide: isWide),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _HeroSlide {
  const _HeroSlide({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.badgeTitle,
    required this.badgeDescription,
  });

  final String imageUrl;
  final String title;
  final String description;
  final String badgeTitle;
  final String badgeDescription;
}

class _HeroImageSlider extends StatefulWidget {
  const _HeroImageSlider({required this.isWide});

  final bool isWide;

  @override
  State<_HeroImageSlider> createState() => _HeroImageSliderState();
}

class _HeroImageSliderState extends State<_HeroImageSlider> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _currentIndex = 0;

  static const _slides = [
    _HeroSlide(
      imageUrl:
          'https://images.unsplash.com/photo-1570913149827-d2ac84ab3f9a?auto=format&fit=crop&w=1300&q=80',
      title: '수확일이 확정된 사과만 예약하세요',
      description: '농가가 확정한 수확 예정 범위와 잔여 수량을 확인합니다.',
      badgeTitle: '10.12-10.18',
      badgeDescription: '문경 햇살 농장 양광 사과 수확 예정',
    ),
    _HeroSlide(
      imageUrl:
          'https://images.unsplash.com/photo-1568702846914-96b305d2aaeb?auto=format&fit=crop&w=1300&q=80',
      title: '수확 후 선별하여 순차 배송',
      description: '예약한 수확 슬롯에 맞춰 신선한 사과를 받아보세요.',
      badgeTitle: '선별 후 배송',
      badgeDescription: '수확한 상품부터 순차적으로 출고합니다.',
    ),
    _HeroSlide(
      imageUrl:
          'https://images.unsplash.com/photo-1474564862106-1f23d10b9d72?auto=format&fit=crop&w=1300&q=80',
      title: '기상과 생육 상황까지 안내',
      description: '수확 일정 변동 가능성을 미리 확인하고 안심하고 예약합니다.',
      badgeTitle: '일정 안내',
      badgeDescription: '기상 상황에 따라 수확 일정이 조정될 수 있습니다.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_controller.hasClients) {
        return;
      }

      final nextIndex = (_currentIndex + 1) % _slides.length;
      _controller.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  void _moveBy(int offset) {
    final nextIndex = (_currentIndex + offset) % _slides.length;
    _goTo(nextIndex < 0 ? _slides.length - 1 : nextIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: _slides.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final slide = _slides[index];
            return Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  slide.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFE3E9DF),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x22000000), Color(0x77000000)],
                    ),
                  ),
                ),
                Positioned(
                  left: 24,
                  right: 24,
                  top: widget.isWide ? 48 : 28,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slide.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              shadows: const [
                                Shadow(blurRadius: 8, color: Color(0x88000000)),
                              ],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        slide.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xEEFFFFFF),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: widget.isWide ? null : 16,
                  right: widget.isWide ? 18 : null,
                  bottom: 18,
                  child: _HeroSlideBadge(slide: slide),
                ),
              ],
            );
          },
        ),
        Positioned(
          left: 12,
          top: 0,
          bottom: 0,
          child: _HeroArrowButton(
            icon: Icons.chevron_left,
            onPressed: () => _moveBy(-1),
          ),
        ),
        Positioned(
          right: 12,
          top: 0,
          bottom: 0,
          child: _HeroArrowButton(
            icon: Icons.chevron_right,
            onPressed: () => _moveBy(1),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var index = 0; index < _slides.length; index += 1)
                _HeroDot(
                  selected: index == _currentIndex,
                  onTap: () => _goTo(index),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroSlideBadge extends StatelessWidget {
  const _HeroSlideBadge({required this.slide});

  final _HeroSlide slide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 185,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xDD163B2B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            slide.badgeTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            slide.badgeDescription,
            style: const TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroArrowButton extends StatelessWidget {
  const _HeroArrowButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton.filledTonal(
        onPressed: onPressed,
        icon: Icon(icon),
        style: IconButton.styleFrom(
          backgroundColor: const Color(0x66000000),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}

class _HeroDot extends StatelessWidget {
  const _HeroDot({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: selected ? 18 : 8,
        height: 8,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0x99FFFFFF),
          borderRadius: BorderRadius.circular(999),
        ),
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
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
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
                const SizedBox(height: 6),
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

class _ParallaxTrustSection extends StatelessWidget {
  const _ParallaxTrustSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 42),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 430,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const _ParallaxBackground(
                imageUrl:
                    'https://images.unsplash.com/photo-1570913149827-d2ac84ab3f9a?auto=format&fit=crop&w=1600&q=80',
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x44000000), Color(0x99000000)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '수확일이 보이는 예약',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Harvest Slot',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '농가가 확정한 수확 예정 범위와 잔여 수량을 기준으로 신선한 사과를 예약하고 배송 상태까지 확인하세요.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: const Color(0xEEFFFFFF),
                                fontWeight: FontWeight.w700,
                                height: 1.55,
                              ),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 18,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: const [
                            _TrustCaption(label: '농가 확정 수확'),
                            _TrustCaption(label: '잔여 수량 확인'),
                            _TrustCaption(label: '수확 후 순차 배송'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParallaxBackground extends StatelessWidget {
  const _ParallaxBackground({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final position = Scrollable.maybeOf(context)?.position;

    if (position == null) {
      return _ParallaxImage(imageUrl: imageUrl, offset: 0);
    }

    return AnimatedBuilder(
      animation: position,
      builder: (context, _) {
        final offset = (position.pixels * 0.08).clamp(-48.0, 48.0);
        return _ParallaxImage(imageUrl: imageUrl, offset: -offset);
      },
    );
  }
}

class _ParallaxImage extends StatelessWidget {
  const _ParallaxImage({required this.imageUrl, required this.offset});

  final String imageUrl;
  final double offset;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, offset),
      child: Transform.scale(
        scale: 1.14,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF143B2A), Color(0xFF2F6F4E)],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TrustCaption extends StatelessWidget {
  const _TrustCaption({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_outline, size: 17, color: Colors.white),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            shadows: const [
              Shadow(
                color: Color(0x99000000),
                blurRadius: 6,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ignore: unused_element
class _TrustSection extends StatelessWidget {
  const _TrustSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 42),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAF4),
          border: Border.all(color: const Color(0xFFDCE3DD)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 880;
              final copy = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '농가 신뢰 안내',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '확정된 수확 일정과 예약 가능 수량만 보여드립니다',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF163B2B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Harvest Slot은 농가가 직접 확인한 수확 예정 범위와 잔여 수량을 기준으로 예약을 받습니다. 고객은 예약 전 수확 일정, 포장 단위, 금액, 배송 상태를 단계별로 확인할 수 있습니다.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.55,
                      color: const Color(0xFF5F6C62),
                    ),
                  ),
                ],
              );

              final cards = Column(
                children: const [
                  _TrustItem(
                    icon: Icons.event_available_outlined,
                    title: '수확 예정 범위 기준',
                    description: '농가가 확정한 기간 안에서 예약 가능한 상품만 안내합니다.',
                  ),
                  SizedBox(height: 12),
                  _TrustItem(
                    icon: Icons.inventory_outlined,
                    title: '잔여 수량 확인',
                    description: '선택한 포장 단위 기준으로 예약 가능 박스 수를 확인합니다.',
                  ),
                  SizedBox(height: 12),
                  _TrustItem(
                    icon: Icons.verified_user_outlined,
                    title: '상태 안내',
                    description: '결제 이후 농가 확인, 선별, 배송 상태를 주문 상세에서 확인합니다.',
                  ),
                ],
              );

              if (!isWide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [copy, const SizedBox(height: 20), cards],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: copy),
                  const SizedBox(width: 24),
                  Expanded(flex: 4, child: cards),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE7F3EB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF17241C),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                  color: const Color(0xFF5F6C62),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VarietySection extends StatelessWidget {
  const _VarietySection();

  @override
  Widget build(BuildContext context) {
    const varieties = [
      _VarietyInfo(
        name: '양광',
        tag: '산뜻한 단맛과 선명한 향',
        description: '과즙이 풍부하고 산뜻한 단맛이 살아 있어 선물용과 가정용으로 두루 즐기기 좋습니다.',
        color: Color(0xFFE6483D),
      ),
      _VarietyInfo(
        name: '부사',
        tag: '단단하고 오래 가는 사과',
        description: '아삭한 식감과 안정적인 단맛이 좋아 가정용으로 오래 두고 먹기 좋습니다.',
        color: Color(0xFFC93845),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 44),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1132),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFDCE3DD)),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '품종 소개',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '예약 전 품종별 특징을 확인해보세요',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF163B2B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Text(
                      '같은 사과라도 품종마다 식감, 향, 보관성, 산미가 다릅니다. 원하는 맛에 맞춰 수확 슬롯을 선택해보세요.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF5F6C62),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final columnCount = width >= 640 ? 2 : 1;
                      final itemWidth =
                          (width - (14 * (columnCount - 1))) / columnCount;

                      return Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: [
                          for (final variety in varieties)
                            SizedBox(
                              width: itemWidth,
                              child: _VarietyCard(variety: variety),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VarietyInfo {
  const _VarietyInfo({
    required this.name,
    required this.tag,
    required this.description,
    required this.color,
  });

  final String name;
  final String tag;
  final String description;
  final Color color;
}

class _VarietyCard extends StatelessWidget {
  const _VarietyCard({required this.variety});

  final _VarietyInfo variety;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE3E8E1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: variety.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(Icons.apple, color: variety.color),
            ),
            const SizedBox(height: 12),
            Text(
              variety.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF17241C),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              variety.tag,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: variety.color,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              variety.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF5F6C62),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StorageSection extends StatelessWidget {
  const _StorageSection();

  @override
  Widget build(BuildContext context) {
    const tips = [
      _StorageTip(
        icon: Icons.ac_unit_outlined,
        title: '수령 후 냉장 보관',
        description: '도착한 사과는 가능한 빨리 냉장 보관하면 신선도를 더 오래 유지할 수 있습니다.',
      ),
      _StorageTip(
        icon: Icons.inventory_2_outlined,
        title: '나누어 보관',
        description: '지퍼백이나 위생팩에 나누어 담아 보관하면 수분 손실을 줄이는 데 도움이 됩니다.',
      ),
      _StorageTip(
        icon: Icons.spa_outlined,
        title: '다른 과일과 분리',
        description: '다른 과일과 함께 두면 숙성이 빨라질 수 있어 따로 보관하는 것을 권장합니다.',
      ),
      _StorageTip(
        icon: Icons.warning_amber_outlined,
        title: '얼지 않게 주의',
        description: '너무 낮은 온도에서 얼면 식감이 변할 수 있으니 냉동에 가까운 보관은 피해주세요.',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 44),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFEEF4EE),
          border: Border.all(color: const Color(0xFFD7E3D8)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final header = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '보관 안내',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '수확 사과를 오래 신선하게 보관하는 방법',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF163B2B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '사과는 수확 후 보관 방법에 따라 식감과 향이 달라질 수 있습니다. 배송 받은 뒤 아래 방법을 참고해 신선하게 즐겨보세요.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.55,
                      color: const Color(0xFF5F6C62),
                    ),
                  ),
                ],
              );

              final list = Column(
                children: [
                  for (var index = 0; index < tips.length; index += 1) ...[
                    _StorageTipTile(tip: tips[index]),
                    if (index != tips.length - 1) const SizedBox(height: 10),
                  ],
                ],
              );

              if (!isWide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [header, const SizedBox(height: 20), list],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: header),
                  const SizedBox(width: 26),
                  Expanded(flex: 5, child: list),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StorageTip {
  const _StorageTip({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

class _StorageTipTile extends StatelessWidget {
  const _StorageTipTile({required this.tip});

  final _StorageTip tip;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E8DF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(tip.icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF17241C),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    tip.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                      color: const Color(0xFF5F6C62),
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

class _EnjoySection extends StatelessWidget {
  const _EnjoySection();

  @override
  Widget build(BuildContext context) {
    const items = [
      _EnjoyItem(
        icon: Icons.restaurant_outlined,
        title: '그대로 씻어 먹기',
        description: '사과 본연의 식감과 향을 가장 잘 느낄 수 있습니다.',
      ),
      _EnjoyItem(
        icon: Icons.eco_outlined,
        title: '샐러드에 곁들이기',
        description: '신선한 채소와 함께 먹으면 산뜻한 단맛이 살아납니다.',
      ),
      _EnjoyItem(
        icon: Icons.bakery_dining_outlined,
        title: '디저트로 즐기기',
        description: '구운 사과, 사과파이, 요거트 토핑으로 활용하기 좋습니다.',
      ),
      _EnjoyItem(
        icon: Icons.local_cafe_outlined,
        title: '주스와 스무디',
        description: '아침이나 간식으로 가볍게 즐기기 좋은 방법입니다.',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 44),
      child: _HomeSectionPanel(
        icon: Icons.restaurant_outlined,
        label: '즐기는 방법',
        title: '수확 사과를 더 맛있게 즐겨보세요',
        description: '예약한 사과를 받은 뒤 바로 먹어도 좋고, 간단한 식사나 디저트로 활용해도 좋습니다.',
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 920;
            if (!isWide) {
              return Column(
                children: [
                  for (var index = 0; index < items.length; index += 1) ...[
                    _EnjoyTile(item: items[index], index: index + 1),
                    if (index != items.length - 1) const SizedBox(height: 12),
                  ],
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < items.length; index += 1) ...[
                  Expanded(
                    child: _EnjoyTile(item: items[index], index: index + 1),
                  ),
                  if (index != items.length - 1) const SizedBox(width: 14),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HomeSectionPanel extends StatelessWidget {
  const _HomeSectionPanel({
    required this.icon,
    required this.label,
    required this.title,
    required this.description,
    required this.child,
  });

  final IconData icon;
  final String label;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE3DD)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFE7F3EB),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF163B2B),
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF5F6C62),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 22),
            child,
          ],
        ),
      ),
    );
  }
}

class _EnjoyItem {
  const _EnjoyItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

class _EnjoyTile extends StatelessWidget {
  const _EnjoyTile({required this.item, required this.index});

  final _EnjoyItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE3DD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F3EB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.icon,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  '0$index',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFFCAD4C9),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              item.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF17241C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.42,
                color: const Color(0xFF5F6C62),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProcessSection extends StatelessWidget {
  const _ProcessSection();

  @override
  Widget build(BuildContext context) {
    const steps = [
      _ProcessStep(
        icon: Icons.search_outlined,
        title: '수확 슬롯 확인',
        description: '품종, 수확 예정 범위, 잔여 수량을 확인합니다.',
      ),
      _ProcessStep(
        icon: Icons.inventory_2_outlined,
        title: '예약함에 담기',
        description: '패키지 단위와 박스 수량을 선택해 예약함에 담습니다.',
      ),
      _ProcessStep(
        icon: Icons.fact_check_outlined,
        title: '예약 전 확인',
        description: '수량, 금액, 수확 일정을 주문 전 다시 확인합니다.',
      ),
      _ProcessStep(
        icon: Icons.payments_outlined,
        title: '주문서와 결제',
        description: '배송 정보를 입력하고 결제를 진행합니다.',
      ),
      _ProcessStep(
        icon: Icons.agriculture_outlined,
        title: '수확과 선별',
        description: '농가 확인 후 수확한 사과를 선별합니다.',
      ),
      _ProcessStep(
        icon: Icons.local_shipping_outlined,
        title: '배송과 반품 안내',
        description: '배송 상태를 확인하고 조건에 따라 반품을 신청합니다.',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 48),
      child: _HomeSectionPanel(
        icon: Icons.route_outlined,
        label: '예약 흐름',
        title: '수확부터 배송까지 한눈에 확인하세요',
        description:
            'Harvest Slot은 농가가 확정한 수확 예정 범위를 기준으로 예약하고, 주문 상세에서 발송 준비와 배송 상태를 단계별로 안내합니다.',
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columnCount = constraints.maxWidth >= 980
                ? 3
                : constraints.maxWidth >= 640
                ? 2
                : 1;

            return GridView.count(
              crossAxisCount: columnCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: columnCount == 1 ? 3.4 : 2.25,
              children: [
                for (var index = 0; index < steps.length; index += 1)
                  _RevealOnLoad(
                    delay: Duration(milliseconds: 90 * index),
                    child: _ProcessCard(index: index + 1, step: steps[index]),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProcessStep {
  const _ProcessStep({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

class _ProcessCard extends StatelessWidget {
  const _ProcessCard({required this.index, required this.step});

  final int index;
  final _ProcessStep step;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE3DD)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D163B2B),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE7F3EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                step.icon,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '0$index',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF17241C),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    step.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5F6C62),
                      height: 1.4,
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

class _FaqSection extends StatelessWidget {
  const _FaqSection();

  @override
  Widget build(BuildContext context) {
    const faqs = [
      _FaqItem(
        question: '수확 일정이 바뀔 수 있나요?',
        answer: '기상과 생육 상황에 따라 수확 일정이 조정될 수 있습니다.',
      ),
      _FaqItem(
        question: '예약한 수량이 변경될 수 있나요?',
        answer: '최종 수량과 금액은 예약 확정 전에 다시 확인됩니다.',
      ),
      _FaqItem(question: '배송은 언제 시작되나요?', answer: '수확 후 선별이 끝난 상품부터 순차 배송됩니다.'),
      _FaqItem(
        question: '반품은 언제 신청할 수 있나요?',
        answer: '배송 완료 후 조건에 따라 반품 신청이 가능합니다.',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 44),
      child: _HomeSectionPanel(
        icon: Icons.help_outline,
        label: '자주 묻는 질문',
        title: '예약 전에 궁금한 점을 확인하세요',
        description: '수확 일정, 예약 수량, 배송과 반품처럼 고객이 자주 확인하는 내용을 모았습니다.',
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            if (!isWide) {
              return Column(
                children: [
                  for (var index = 0; index < faqs.length; index += 1) ...[
                    _FaqTile(item: faqs[index]),
                    if (index != faqs.length - 1) const SizedBox(height: 10),
                  ],
                ],
              );
            }

            return GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 3.7,
              children: [for (final faq in faqs) _FaqTile(item: faq)],
            );
          },
        ),
      ),
    );
  }
}

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.item});

  final _FaqItem item;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE3DD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.help_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.question,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF17241C),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.answer,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                      color: const Color(0xFF5F6C62),
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

class _CleanSupportFooter extends StatelessWidget {
  const _CleanSupportFooter();

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.sizeOf(context).width < 720 ? 112.0 : 40.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 860;
              final cards = [
                const _CleanSupportCard(
                  icon: Icons.support_agent_outlined,
                  title: '고객센터',
                  description: '예약, 배송, 반품 문의를 도와드립니다.',
                  primary: '010-8953-2362',
                  secondary: '평일 AM 09:00 - PM 06:00',
                  primaryAction: _SupportAction.phone,
                ),
                const _CleanSupportCard(
                  icon: Icons.info_outline,
                  title: 'Harvest Slot 안내',
                  description: '수확 일정은 기상과 생육 상황에 따라 조정될 수 있습니다.',
                  primary: '배송 완료 후 반품 신청 가능',
                  secondary: '주문 상세에서 배송 상태를 확인하세요.',
                ),
              ];

              if (!isWide) {
                return Column(
                  children: [
                    for (var index = 0; index < cards.length; index += 1) ...[
                      cards[index],
                      if (index != cards.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 16),
                  Expanded(child: cards[1]),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          const Divider(height: 1),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;
              final company = Text(
                '상호: Harvest Slot | 수확 슬롯 기반 사과 예약 서비스\n'
                'E-MAIL: support@harvestslot.kr | Copyright Harvest Slot. All Rights Reserved.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.6,
                  color: const Color(0xFF5F6C62),
                ),
              );
              final links = Wrap(
                spacing: 16,
                runSpacing: 8,
                alignment: isWide ? WrapAlignment.end : WrapAlignment.start,
                children: [
                  _FooterLink(label: '이용약관', document: _PolicyDocument.terms),
                  _FooterLink(
                    label: '개인정보처리방침',
                    document: _PolicyDocument.privacy,
                  ),
                  const _FooterLink(
                    label: '이메일 문의',
                    supportAction: _SupportAction.email,
                  ),
                ],
              );

              if (!isWide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [company, const SizedBox(height: 12), links],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: company),
                  const SizedBox(width: 18),
                  links,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

enum _SupportAction { phone, email }

enum _PolicyDocument { terms, privacy }

Future<void> _openSupportAction(
  BuildContext context,
  _SupportAction action,
) async {
  final uri = switch (action) {
    _SupportAction.phone => Uri(scheme: 'tel', path: '01089532362'),
    _SupportAction.email => Uri(
      scheme: 'mailto',
      path: 'support@harvestslot.kr',
    ),
  };
  final failedMessage = switch (action) {
    _SupportAction.phone => '전화 앱을 열 수 없습니다. 010-8953-2362로 직접 연락해주세요.',
    _SupportAction.email =>
      '메일 앱을 열 수 없습니다. support@harvestslot.kr로 직접 문의해주세요.',
  };

  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    await showAppAlertDialog(context, message: failedMessage);
  }
}

class _CleanSupportCard extends StatelessWidget {
  const _CleanSupportCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.primary,
    required this.secondary,
    this.primaryAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String primary;
  final String secondary;
  final _SupportAction? primaryAction;

  Widget _supportTextButton({
    required BuildContext context,
    required String text,
    required TextStyle? style,
    required _SupportAction? action,
  }) {
    if (action == null) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => _openSupportAction(context, action),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                action == _SupportAction.phone
                    ? Icons.call_outlined
                    : Icons.mail_outline,
                size: 17,
                color: const Color(0xFF163B2B),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF0E4DA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: title,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        TextSpan(text: ' | $description'),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF38322D),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _supportTextButton(
                    context: context,
                    text: primary,
                    action: primaryAction,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF17241C),
                      decoration: primaryAction == null
                          ? TextDecoration.none
                          : TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(height: 5),
                  _supportTextButton(
                    context: context,
                    text: secondary,
                    action: null,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF38322D),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Icon(icon, size: 42, color: const Color(0xFF4A4540)),
          ],
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, this.supportAction, this.document});

  final String label;
  final _SupportAction? supportAction;
  final _PolicyDocument? document;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () {
        final action = supportAction;
        if (action != null) {
          _openSupportAction(context, action);
          return;
        }

        final policyDocument = document;
        if (policyDocument != null) {
          _showPolicyDialog(context, policyDocument);
          return;
        }

        showAppAlertDialog(context, message: '준비 중인 메뉴입니다.');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFF163B2B),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

Future<void> _showPolicyDialog(BuildContext context, _PolicyDocument document) {
  final content = _policyContent(document);
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(content.title),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Text(
              content.body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.65,
                color: const Color(0xFF2D3A31),
              ),
            ),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      );
    },
  );
}

({String title, String body}) _policyContent(_PolicyDocument document) {
  return switch (document) {
    _PolicyDocument.terms => (
      title: '이용약관',
      body:
          '제1조 목적\n'
          '이 약관은 Harvest Slot이 제공하는 수확 슬롯 기반 농산물 예약 서비스의 이용 조건과 절차, 회원과 서비스의 권리 및 의무를 정합니다.\n\n'
          '제2조 서비스 내용\n'
          'Harvest Slot은 고객이 농가가 등록한 상품과 수확 예정 슬롯을 확인하고, 예약, 주문, 결제, 배송 조회, 반품 요청을 진행할 수 있도록 돕는 온라인 예약 서비스를 제공합니다.\n\n'
          '제3조 회원 이용\n'
          '회원은 정확한 정보를 입력해야 하며, 다른 사람의 정보를 사용하거나 서비스 운영을 방해해서는 안 됩니다. 회원 정보가 변경된 경우 서비스 화면 또는 고객센터를 통해 최신 정보로 유지해야 합니다.\n\n'
          '제4조 예약과 주문\n'
          '수확 예정일과 잔여 수량은 농가의 확인, 기상, 생육 상황에 따라 조정될 수 있습니다. 고객은 주문 전 상품명, 수량, 금액, 배송지 정보를 확인한 뒤 결제를 진행해야 합니다.\n\n'
          '제5조 결제와 취소\n'
          '결제가 완료된 주문은 농가 확인 및 배송 준비 단계로 진행됩니다. 취소 가능 여부와 환불 기준은 주문 상태, 상품 준비 여부, 배송 진행 여부에 따라 달라질 수 있습니다.\n\n'
          '제6조 배송과 반품\n'
          '배송 완료 후 상품 파손, 변질, 오배송 등 문제가 있는 경우 고객은 증빙 사진과 상세 사유를 첨부해 반품을 요청할 수 있습니다. 환불 가능 금액은 접수 내용과 상품 상태 확인 결과에 따라 안내됩니다.\n\n'
          '제7조 서비스 변경\n'
          '서비스는 운영상 필요에 따라 화면, 기능, 제공 범위가 변경될 수 있습니다. 중요한 변경 사항은 서비스 화면 또는 별도 안내를 통해 고지합니다.\n\n'
          '제8조 문의\n'
          '서비스 이용 중 문의가 필요한 경우 고객센터 또는 이메일 support@harvestslot.kr로 연락할 수 있습니다.\n\n'
          '시행일: 2026년 5월 11일',
    ),
    _PolicyDocument.privacy => (
      title: '개인정보처리방침',
      body:
          '1. 수집하는 개인정보\n'
          'Harvest Slot은 회원가입, 주문, 배송, 고객 응대를 위해 이름, 이메일, 휴대폰번호, 배송지, 주문 및 결제 내역, 반품 요청 내용을 수집할 수 있습니다.\n\n'
          '2. 개인정보 이용 목적\n'
          '수집한 정보는 회원 식별, 이메일 인증, 예약 및 주문 처리, 결제 확인, 배송 안내, 반품 및 환불 처리, 고객 문의 응대, 서비스 품질 개선에 사용됩니다.\n\n'
          '3. 보관 및 이용 기간\n'
          '개인정보는 서비스 이용 기간 동안 보관하며, 회원 탈퇴 또는 처리 목적 달성 시 지체 없이 파기합니다. 다만 관련 법령에 따라 보관이 필요한 주문, 결제, 소비자 분쟁 관련 기록은 정해진 기간 동안 보관할 수 있습니다.\n\n'
          '4. 제3자 제공\n'
          'Harvest Slot은 원칙적으로 고객의 개인정보를 외부에 제공하지 않습니다. 단, 배송 처리, 결제 확인, 법령상 의무 이행 등 서비스 제공에 필요한 범위에서는 최소한의 정보가 처리될 수 있습니다.\n\n'
          '5. 개인정보 보호 조치\n'
          '서비스는 개인정보가 분실, 도난, 유출, 변조되지 않도록 접근 권한 관리와 안전한 저장 및 전송 절차를 적용합니다.\n\n'
          '6. 이용자의 권리\n'
          '고객은 본인의 개인정보 열람, 수정, 삭제, 처리 정지를 요청할 수 있습니다. 서비스 화면에서 직접 수정할 수 없는 정보는 고객센터를 통해 요청할 수 있습니다.\n\n'
          '7. 문의처\n'
          '개인정보 관련 문의는 support@harvestslot.kr로 접수할 수 있습니다.\n\n'
          '시행일: 2026년 5월 11일',
    ),
  };
}

// ignore: unused_element
class _SupportFooter extends StatelessWidget {
  const _SupportFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 820;
              final cards = [
                const _SupportCard(
                  icon: Icons.support_agent_outlined,
                  title: '고객센터',
                  description: '예약, 배송, 반품 문의를 도와드립니다.',
                  primary: '010-0000-0000',
                  secondary: '평일 AM 09:00 - PM 06:00',
                ),
                const _SupportCard(
                  icon: Icons.info_outline,
                  title: 'Harvest Slot 안내',
                  description: '수확 일정은 기상과 생육 상황에 따라 조정될 수 있습니다.',
                  primary: '배송 완료 후 조건에 따라 반품 신청 가능',
                  secondary: '주문 상세에서 배송 상태를 확인하세요.',
                ),
              ];

              if (!isWide) {
                return Column(
                  children: [
                    for (var index = 0; index < cards.length; index += 1) ...[
                      cards[index],
                      if (index != cards.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 14),
                  Expanded(child: cards[1]),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;
              final company = Text(
                '상호: Harvest Slot | E-MAIL: support@harvestslot.kr\n'
                '수확 슬롯 기반 사과 예약 서비스 | Copyright Harvest Slot. All Rights Reserved.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.6,
                  color: const Color(0xFF5F6C62),
                ),
              );
              final links = Wrap(
                spacing: 16,
                runSpacing: 8,
                alignment: isWide ? WrapAlignment.end : WrapAlignment.start,
                children: [
                  Text(
                    '이용약관',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF163B2B),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '개인정보처리방침',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF163B2B),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              );

              if (!isWide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [company, const SizedBox(height: 14), links],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: company),
                  const SizedBox(width: 18),
                  links,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.primary,
    required this.secondary,
  });

  final IconData icon;
  final String title;
  final String description;
  final String primary;
  final String secondary;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEFE3D8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: title,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        TextSpan(text: ' | $description'),
                      ],
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF38322D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    primary,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF17241C),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    secondary,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF38322D),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Icon(icon, size: 54, color: const Color(0xFF4A4540)),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.icon, required this.text, this.onTap});

  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
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
        ),
      ),
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
        final isLoggedIn = MockAuthSession.isLoggedIn;
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
                      if (isLoggedIn)
                        _TopAction(
                          label: '마이페이지',
                          routeName: AppRoutes.myPage,
                          compact: isCompact,
                        ),
                      if (!isLoggedIn)
                        _TopAction(
                          label: '회원가입',
                          routeName: AppRoutes.signup,
                          compact: isCompact,
                        ),
                      if (!isLoggedIn)
                        _TopAction(
                          label: '로그인',
                          routeName: AppRoutes.login,
                          compact: isCompact,
                        ),
                      if (isLoggedIn) _LogoutAction(compact: isCompact),
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
    final effectiveLabel = switch (routeName) {
      AppRoutes.products => '상품',
      AppRoutes.myOrders => '내 주문',
      AppRoutes.myPage => '마이페이지',
      AppRoutes.signup => '회원가입',
      AppRoutes.login => '로그인',
      _ => label,
    };

    return TextButton(
      onPressed: () => Navigator.pushNamed(context, routeName),
      style: TextButton.styleFrom(
        minimumSize: Size(compact ? 48 : 64, 40),
        padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 14),
      ),
      child: Text(
        effectiveLabel,
        maxLines: 1,
        style: TextStyle(
          fontSize: compact ? 13 : 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LogoutAction extends StatelessWidget {
  const _LogoutAction({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        MockAuthSession.logout();
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      },
      style: TextButton.styleFrom(
        minimumSize: Size(compact ? 48 : 64, 40),
        padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 14),
      ),
      child: Text(
        '로그아웃',
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
