import 'dart:async';

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../app/router.dart';
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
                    child: _RevealOnLoad(
                      delay: Duration.zero,
                      child: _HeroSection(
                        onProductsTap: () =>
                            Navigator.pushNamed(context, AppRoutes.products),
                        onFeaturedTap: () =>
                            Navigator.pushNamed(context, AppRoutes.products),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _ConstrainedContent(
                    child: _RevealOnLoad(
                      delay: const Duration(milliseconds: 140),
                      child: _SectionHeader(
                        title: '이번 주 오픈 수확 슬롯',
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
                    child: _ConstrainedContent(child: const _VarietySection()),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _RevealOnLoad(
                    delay: const Duration(milliseconds: 450),
                    child: _ConstrainedContent(child: const _StorageSection()),
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
                    child: _ConstrainedContent(child: const _ProcessSection()),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _RevealOnLoad(
                    delay: const Duration(milliseconds: 480),
                    child: _ConstrainedContent(child: const _FaqSection()),
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
                    SizedBox(
                      height: 205,
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
                    Expanded(flex: 95, child: _HeroImageSlider(isWide: isWide)),
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
      badgeDescription: '충주 햇살농원 후지 사과 수확 예정',
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
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: const [
                            _TrustBadge(
                              icon: Icons.event_available_outlined,
                              label: '농가 확정 수확',
                            ),
                            _TrustBadge(
                              icon: Icons.inventory_outlined,
                              label: '잔여 수량 확인',
                            ),
                            _TrustBadge(
                              icon: Icons.local_shipping_outlined,
                              label: '수확 후 순차 배송',
                            ),
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

class _TrustBadge extends StatelessWidget {
  const _TrustBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xCCFFFFFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF163B2B)),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: const Color(0xFF163B2B),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
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
        name: '후지',
        tag: '저장성 좋은 기본 사과',
        description: '단단한 식감과 안정적인 단맛으로 오래 두고 먹기 좋습니다.',
        color: Color(0xFFE6483D),
      ),
      _VarietyInfo(
        name: '홍로',
        tag: '향이 좋은 선물용',
        description: '향과 단맛이 좋아 추석 전후 선물용으로도 잘 어울립니다.',
        color: Color(0xFFC93845),
      ),
      _VarietyInfo(
        name: '시나노골드',
        tag: '산뜻한 노란 사과',
        description: '단맛과 산미의 균형이 좋아 산뜻하게 즐기기 좋습니다.',
        color: Color(0xFFD8A92B),
      ),
      _VarietyInfo(
        name: '감홍',
        tag: '진한 단맛과 풍부한 향',
        description: '당도가 높고 향이 진해 깊은 맛을 선호하는 고객에게 좋습니다.',
        color: Color(0xFF9D2E3A),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 44),
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
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Text(
            '같은 사과라도 품종마다 식감, 향, 보관성, 산미가 다릅니다. 원하는 맛에 맞춰 수확 슬롯을 선택해보세요.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF5F6C62),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final columnCount = constraints.maxWidth >= 980
                  ? 4
                  : constraints.maxWidth >= 640
                  ? 2
                  : 1;

              return GridView.count(
                crossAxisCount: columnCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: columnCount == 1
                    ? 2.6
                    : columnCount == 2
                    ? 1.35
                    : 1.15,
                children: [
                  for (final variety in varieties)
                    _VarietyCard(variety: variety),
                ],
              );
            },
          ),
        ],
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
        border: Border.all(color: const Color(0xFFDCE3DD)),
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
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final header = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
        border: Border.all(color: const Color(0xFFDCE3DD)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '즐기는 방법',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '수확 사과를 더 맛있게 즐겨보세요',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Text(
            '예약한 사과를 받은 뒤 바로 먹어도 좋고, 간단한 식사나 디저트로 활용해도 좋습니다.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF5F6C62),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
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
        ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '예약 흐름',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const _RevealOnLoad(
            delay: Duration(milliseconds: 80),
            child: _ProcessTitleText(),
          ),
          const SizedBox(height: 12),
          const _RevealOnLoad(
            delay: Duration(milliseconds: 160),
            child: _ProcessDescriptionText(),
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
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
        ],
      ),
    );
  }
}

class _ProcessTitleText extends StatelessWidget {
  const _ProcessTitleText();

  @override
  Widget build(BuildContext context) {
    return Text(
      '수확부터 배송까지 한눈에 확인하세요',
      style: Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
    );
  }
}

class _ProcessDescriptionText extends StatelessWidget {
  const _ProcessDescriptionText();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Harvest Slot은 농가가 확정한 수확 예정 범위를 기준으로 예약하고, 주문 상세에서 선별과 배송 상태를 단계별로 안내합니다.',
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: const Color(0xFF5F6C62),
        height: 1.5,
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
        answer: '최종 수량과 금액은 예약 생성 단계에서 다시 확인됩니다.',
      ),
      _FaqItem(question: '배송은 언제 시작되나요?', answer: '수확 후 선별이 끝난 상품부터 순차 배송됩니다.'),
      _FaqItem(
        question: '반품은 언제 신청할 수 있나요?',
        answer: '배송 완료 후 조건에 따라 반품 신청이 가능합니다.',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 44),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '자주 묻는 질문',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '예약 전에 궁금한 점을 확인하세요',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
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
        ],
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
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
                  primary: '010-0000-0000',
                  secondary: '평일 AM 09:00 - PM 06:00',
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
                  _FooterLink(
                    label: '이용약관',
                    message: '이용약관 페이지는 백엔드 연결 후 별도 화면으로 확장할 수 있습니다.',
                  ),
                  _FooterLink(
                    label: '개인정보처리방침',
                    message: '개인정보처리방침 페이지는 백엔드 연결 후 별도 화면으로 확장할 수 있습니다.',
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

class _CleanSupportCard extends StatelessWidget {
  const _CleanSupportCard({
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
                  Text(
                    primary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF17241C),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    secondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
  const _FooterLink({required this.label, required this.message});

  final String label;
  final String message;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () => showAppAlertDialog(context, message: message),
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
