import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/session/mock_auth_session.dart';
import '../../view_models/my_page_view_model.dart';
import '../../widgets/brand_app_bar_title.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late final MyPageViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MyPageViewModel()..load();
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F1E5), Color(0xFFEEF4EE), Color(0xFFF7F7F1)],
            stops: [0, 0.48, 1],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: AnimatedBuilder(
              animation: _viewModel,
              builder: (context, _) {
                if (_viewModel.isLoading && _viewModel.profile == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_viewModel.errorMessage != null &&
                    _viewModel.profile == null) {
                  return _ErrorState(
                    message: _viewModel.errorMessage!,
                    onRetry: _viewModel.load,
                  );
                }

                final profile = _viewModel.profile;
                return CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(child: _MyPageHeader()),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
                        child: _SummaryCard(
                          name: profile?.name ?? '고객',
                          email: profile?.email ?? '',
                          defaultShippingAddress:
                              profile?.defaultShippingAddress,
                          onRecentOrderTap: () =>
                              Navigator.pushNamed(context, AppRoutes.myOrders),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                        child: _ActionGrid(
                          onLogout: () {
                            MockAuthSession.logout();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.home,
                              (route) => false,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _MyPageHeader extends StatelessWidget {
  const _MyPageHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '마이페이지',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '내 예약과 배송 정보를 관리해요',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF163B2B),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '주문 상태, 기본 배송지, 회원 정보를 한곳에서 확인할 수 있습니다.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF5F6C62),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.name,
    required this.email,
    required this.defaultShippingAddress,
    required this.onRecentOrderTap,
  });

  final String name;
  final String email;
  final String? defaultShippingAddress;
  final VoidCallback onRecentOrderTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF163B2B),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 760;
            final account = _AccountSummary(
              name: name,
              email: email,
              onRecentOrderTap: onRecentOrderTap,
            );
            final stats = Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                const _SummaryMetric(label: '진행 중 주문', value: '확인 예정'),
                const _SummaryMetric(label: '최근 주문 상태', value: '내역 확인'),
                _SummaryMetric(
                  label: '기본 배송지',
                  value: defaultShippingAddress?.isNotEmpty == true
                      ? defaultShippingAddress!
                      : '미등록',
                ),
              ],
            );

            if (!isWide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [account, const SizedBox(height: 18), stats],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 5, child: account),
                const SizedBox(width: 18),
                Expanded(flex: 4, child: stats),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AccountSummary extends StatelessWidget {
  const _AccountSummary({
    required this.name,
    required this.email,
    required this.onRecentOrderTap,
  });

  final String name;
  final String email;
  final VoidCallback onRecentOrderTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFFE7F3EB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.person_outline, color: Color(0xFF163B2B)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xCCFFFFFF),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onRecentOrderTap,
                icon: const Icon(Icons.local_shipping_outlined),
                label: const Text('주문 내역 확인'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0x99FFFFFF)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        border: Border.all(color: const Color(0x33FFFFFF)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: const Color(0xCCFFFFFF),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 860;
        final cards = [
          _MyPageActionCard(
            icon: Icons.receipt_long_outlined,
            title: '내 주문',
            description: '예약 상품의 결제, 선별, 배송 상태를 확인합니다.',
            buttonLabel: '주문 내역 보기',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.myOrders),
          ),
          _MyPageActionCard(
            icon: Icons.location_on_outlined,
            title: '기본 배송지 관리',
            description: '주문 작성 전에 사용할 배송지를 확인합니다.',
            buttonLabel: '배송지 확인',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.addressManage),
          ),
          _MyPageActionCard(
            icon: Icons.person_outline,
            title: '회원 정보',
            description: '이름, 연락처, 이메일 정보를 확인합니다.',
            buttonLabel: '회원 정보 보기',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.memberInfo),
          ),
          _MyPageActionCard(
            icon: Icons.assignment_return_outlined,
            title: '반품 내역',
            description: '접수한 반품 요청과 처리 상태를 확인합니다.',
            buttonLabel: '반품 내역 보기',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.myReturns),
          ),
          _MyPageActionCard(
            icon: Icons.logout,
            title: '로그아웃',
            description: '현재 로그인 상태를 종료하고 홈으로 이동합니다.',
            buttonLabel: '로그아웃',
            onPressed: onLogout,
          ),
        ];

        if (!isWide) {
          return Column(
            children: [
              for (final card in cards) ...[card, const SizedBox(height: 14)],
            ],
          );
        }

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 2.75,
          children: cards,
        );
      },
    );
  }
}

class _MyPageActionCard extends StatelessWidget {
  const _MyPageActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onPressed;

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
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5F6C62),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton(
                      onPressed: onPressed,
                      child: Text(buttonLabel),
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ),
      ),
    );
  }
}
