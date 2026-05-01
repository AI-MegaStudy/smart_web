import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/session/mock_auth_session.dart';
import '../../widgets/app_alert_dialog.dart';
import '../../widgets/brand_app_bar_title.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

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
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: _MyPageHeader()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 860;
                        final cards = [
                          _MyPageActionCard(
                            icon: Icons.receipt_long_outlined,
                            title: '내 주문',
                            description: '예약한 상품의 결제, 선별, 배송 상태를 확인합니다.',
                            buttonLabel: '주문 내역 보기',
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.myOrders,
                            ),
                          ),
                          _MyPageActionCard(
                            icon: Icons.location_on_outlined,
                            title: '기본 배송지 관리',
                            description: '주문서 작성 때 먼저 사용할 배송지를 확인합니다.',
                            buttonLabel: '배송지 확인',
                            onPressed: () => showAppAlertDialog(
                              context,
                              message: '배송지 추가와 카카오 주소 API 연동은 추후 연결 예정입니다.',
                            ),
                          ),
                          _MyPageActionCard(
                            icon: Icons.person_outline,
                            title: '회원 정보',
                            description: '이름, 연락처, 이메일 정보를 확인합니다.',
                            buttonLabel: '회원 정보 보기',
                            onPressed: () => showAppAlertDialog(
                              context,
                              message: '회원 정보 수정은 백엔드 로그인 연결 후 확장할 예정입니다.',
                            ),
                          ),
                          _MyPageActionCard(
                            icon: Icons.logout,
                            title: '로그아웃',
                            description: '현재 로그인 상태를 종료하고 홈으로 이동합니다.',
                            buttonLabel: '로그아웃',
                            onPressed: () {
                              MockAuthSession.logout();
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.home,
                                (route) => false,
                              );
                            },
                          ),
                        ];

                        if (!isWide) {
                          return Column(
                            children: [
                              const _DefaultAddressPanel(),
                              const SizedBox(height: 14),
                              for (final card in cards) ...[
                                card,
                                const SizedBox(height: 14),
                              ],
                            ],
                          );
                        }

                        return Column(
                          children: [
                            const _DefaultAddressPanel(),
                            const SizedBox(height: 16),
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 2.75,
                              children: cards,
                            ),
                          ],
                        );
                      },
                    ),
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

class _MyPageHeader extends StatelessWidget {
  const _MyPageHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
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
            '내 예약과 배송 정보를 관리하세요',
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

class _DefaultAddressPanel extends StatelessWidget {
  const _DefaultAddressPanel();

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFE7F3EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.home_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '기본 배송지',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '홍길동 · 010-1111-2222',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '서울시 강남구 테헤란로 123',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
