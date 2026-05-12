import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../app/router.dart';
import '../data/repositories/local_basket_repository.dart';
import '../presentation/view_models/auth_view_model.dart';
import 'customer_demo_route_defaults.dart';
import 'customer_demo_seed_data.dart';
import 'customer_demo_target_keys.dart';

enum CustomerCoachTourStage {
  signup,
  verifyEmail,
  login,
  homeProductsCta,
  homeFeaturedCta,
  homeQuickNav,
  productList,
  productDetailPackage,
  productDetailSlot,
  productDetail,
  basket,
  reservationConfirm,
  checkout,
  paymentMethod,
  payment,
  orderComplete,
  orderDetail,
  returnRequest,
}

class CustomerCoachTourManager {
  CustomerCoachTourManager._();

  static final CustomerCoachTourManager instance = CustomerCoachTourManager._();

  TutorialCoachMark? _coachMark;
  final LocalBasketRepository _localBasketRepository = LocalBasketRepository();
  CustomerCoachTourStage? _activeStage;
  bool _isRunning = false;
  bool _isDemoMode = false;

  bool get isRunning => _isRunning;
  bool get isDemoMode => _isDemoMode;

  void startFromSignup(BuildContext context) {
    if (_isRunning) {
      return;
    }

    _isDemoMode = true;
    _isRunning = true;
    _activeStage = CustomerCoachTourStage.signup;
    onPageReady(CustomerCoachTourStage.signup, context);
  }

  void startFromHome(BuildContext context) {
    if (_isRunning) {
      return;
    }

    _isDemoMode = true;
    _isRunning = true;
    _activeStage = CustomerCoachTourStage.homeProductsCta;
    onPageReady(CustomerCoachTourStage.homeProductsCta, context);
  }

  Future<void> onPageReady(
    CustomerCoachTourStage stage,
    BuildContext context,
  ) async {
    if (!_isRunning || _activeStage != stage) {
      return;
    }

    final targetKey = _targetKeyForStage(stage);
    if (targetKey == null || targetKey.currentContext == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future<void>.delayed(const Duration(milliseconds: 200), () {
          if (context.mounted) {
            onPageReady(stage, context);
          }
        });
      });
      return;
    }

    await Scrollable.ensureVisible(
      targetKey.currentContext!,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.14,
    );

    if (!_isRunning || _activeStage != stage) {
      return;
    }

    final target = _targetForStage(stage);
    if (target == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future<void>.delayed(const Duration(milliseconds: 200), () {
          if (context.mounted) {
            onPageReady(stage, context);
          }
        });
      });
      return;
    }

    _showStage(stage, target);
  }

  void stop() {
    _coachMark?.removeOverlayEntry();
    _coachMark = null;
    _activeStage = null;
    _isRunning = false;
  }

  GlobalKey? _targetKeyForStage(CustomerCoachTourStage stage) {
    return switch (stage) {
      CustomerCoachTourStage.signup =>
        CustomerDemoTargetKeys.signupPrimaryAction,
      CustomerCoachTourStage.verifyEmail =>
        CustomerDemoTargetKeys.verifyEmailPrimaryAction,
      CustomerCoachTourStage.login => CustomerDemoTargetKeys.loginPrimaryAction,
      CustomerCoachTourStage.homeProductsCta =>
        CustomerDemoTargetKeys.homeProductsButton,
      CustomerCoachTourStage.homeFeaturedCta =>
        CustomerDemoTargetKeys.homeFeaturedButton,
      CustomerCoachTourStage.homeQuickNav => CustomerDemoTargetKeys.homeQuickNav,
      CustomerCoachTourStage.productList =>
        CustomerDemoTargetKeys.productListFirstCard,
      CustomerCoachTourStage.productDetailPackage =>
        CustomerDemoTargetKeys.productDetailPackageSelector,
      CustomerCoachTourStage.productDetailSlot =>
        CustomerDemoTargetKeys.productDetailSlotSelector,
      CustomerCoachTourStage.productDetail =>
        CustomerDemoTargetKeys.productDetailAddToBasket,
      CustomerCoachTourStage.basket => CustomerDemoTargetKeys.basketPrimaryAction,
      CustomerCoachTourStage.reservationConfirm =>
        CustomerDemoTargetKeys.reservationConfirmPrimaryAction,
      CustomerCoachTourStage.checkout =>
        CustomerDemoTargetKeys.checkoutPrimaryAction,
      CustomerCoachTourStage.paymentMethod =>
        CustomerDemoTargetKeys.paymentMethodSelector,
      CustomerCoachTourStage.payment =>
        CustomerDemoTargetKeys.paymentPrimaryAction,
      CustomerCoachTourStage.orderComplete =>
        CustomerDemoTargetKeys.orderCompletePrimaryAction,
      CustomerCoachTourStage.orderDetail => CustomerDemoTargetKeys.orderTimeline,
      CustomerCoachTourStage.returnRequest =>
        CustomerDemoTargetKeys.returnRequestPrimaryAction,
    };
  }

  TargetFocus? _targetForStage(CustomerCoachTourStage stage) {
    return switch (stage) {
      CustomerCoachTourStage.signup => _buildTarget(
        id: 'customer.signup',
        key: CustomerDemoTargetKeys.signupPrimaryAction,
        title: '회원가입',
        description: '처음 이용하는 고객은 이메일과 기본 정보를 입력한 뒤 인증 단계로 이동합니다.',
        align: ContentAlign.bottom,
      ),
      CustomerCoachTourStage.verifyEmail => _buildTarget(
        id: 'customer.verify-email',
        key: CustomerDemoTargetKeys.verifyEmailPrimaryAction,
        title: '이메일 인증',
        description: '이메일로 받은 인증 코드를 확인해 회원가입을 완료하는 단계입니다.',
        align: ContentAlign.bottom,
      ),
      CustomerCoachTourStage.login => _buildTarget(
        id: 'customer.login',
        key: CustomerDemoTargetKeys.loginPrimaryAction,
        title: '로그인',
        description: '인증을 마친 고객은 로그인 후 예약과 주문, 배송 조회 기능을 이용할 수 있습니다.',
        align: ContentAlign.top,
      ),
      CustomerCoachTourStage.homeProductsCta => _buildTarget(
        id: 'customer.home.products.cta',
        key: CustomerDemoTargetKeys.homeProductsButton,
        title: '예약 상품 보기',
        description: '고객이 지금 바로 예약 가능한 상품 목록으로 이동하는 대표 진입 버튼입니다.',
        align: ContentAlign.bottom,
      ),
      CustomerCoachTourStage.homeFeaturedCta => _buildTarget(
        id: 'customer.home.featured.cta',
        key: CustomerDemoTargetKeys.homeFeaturedButton,
        title: '대표 상품',
        description: '대표 상품 상세로 바로 이동해 핵심 예약 흐름을 빠르게 시작할 수 있습니다.',
        align: ContentAlign.bottom,
      ),
      CustomerCoachTourStage.homeQuickNav => _buildTarget(
        id: 'customer.home.quick-nav',
        key: CustomerDemoTargetKeys.homeQuickNav,
        title: '홈 빠른 이동 메뉴',
        description: '상품, 품종, 보관, 농촌, FAQ 섹션으로 빠르게 이동하며 홈 전체 구성을 소개하는 화면입니다.',
        align: ContentAlign.custom,
        customPosition: _homeQuickNavBubblePosition(),
      ),
      CustomerCoachTourStage.productList => _buildTarget(
        id: 'customer.product.list',
        key: CustomerDemoTargetKeys.productListFirstCard,
        title: '상품 목록',
        description: '예약 가능한 상품과 수확 예정 범위를 확인하고, 원하는 상품 상세로 이동하는 단계입니다.',
        align: ContentAlign.bottom,
      ),
      CustomerCoachTourStage.productDetailPackage => _buildTarget(
        id: 'customer.product.detail.package',
        key: CustomerDemoTargetKeys.productDetailPackageSelector,
        title: '패키지 단위 선택',
        description: '먼저 원하는 박스 단위를 선택합니다. 패키지에 따라 중량과 가격이 달라집니다.',
        align: ContentAlign.bottom,
      ),
      CustomerCoachTourStage.productDetailSlot => _buildTarget(
        id: 'customer.product.detail.slot',
        key: CustomerDemoTargetKeys.productDetailSlotSelector,
        title: '수확 슬롯 선택',
        description: '다음으로 수확 예정 범위를 선택합니다. 농가가 확정한 일정 안에서 예약을 진행합니다.',
        align: ContentAlign.bottom,
      ),
      CustomerCoachTourStage.productDetail => _buildTarget(
        id: 'customer.product.detail',
        key: CustomerDemoTargetKeys.productDetailAddToBasket,
        title: '예약함에 담기',
        description: '선택한 패키지와 수확 슬롯을 확인한 뒤 예약함에 담아 다음 단계로 이동합니다.',
        align: ContentAlign.top,
      ),
      CustomerCoachTourStage.basket => _buildTarget(
        id: 'customer.basket',
        key: CustomerDemoTargetKeys.basketPrimaryAction,
        title: '예약함',
        description: '담아둔 상품, 수량, 금액을 확인한 뒤 예약 확인 단계로 이동합니다.',
        align: ContentAlign.bottom,
      ),
      CustomerCoachTourStage.reservationConfirm => _buildTarget(
        id: 'customer.reservation.confirm',
        key: CustomerDemoTargetKeys.reservationConfirmPrimaryAction,
        title: '예약 확인',
        description: '최종 예약 수량과 예상 금액을 확인하고 실제 주문서 작성 단계로 넘어갑니다.',
        align: ContentAlign.bottom,
      ),
      CustomerCoachTourStage.checkout => _buildTarget(
        id: 'customer.checkout',
        key: CustomerDemoTargetKeys.checkoutPrimaryAction,
        title: '주문서 작성',
        description: '받는 분과 배송지를 입력하고, 결제 전 주문 내용을 한 번 더 점검하는 단계입니다.',
        align: ContentAlign.bottom,
      ),
      CustomerCoachTourStage.paymentMethod => _buildTarget(
        id: 'customer.payment.method',
        key: CustomerDemoTargetKeys.paymentMethodSelector,
        title: '결제 수단',
        description: '카드 간편결제, 무통장 입금, 카카오페이, 네이버페이 수단을 확인할 수 있습니다.',
        align: ContentAlign.top,
      ),
      CustomerCoachTourStage.payment => _buildTarget(
        id: 'customer.payment',
        key: CustomerDemoTargetKeys.paymentPrimaryAction,
        title: '결제',
        description: '결제 수단과 최종 결제 금액을 확인하고 주문을 완료하는 단계입니다.',
        align: ContentAlign.bottom,
      ),
      CustomerCoachTourStage.orderComplete => _buildTarget(
        id: 'customer.order.complete',
        key: CustomerDemoTargetKeys.orderCompletePrimaryAction,
        title: '주문 완료',
        description: '주문 번호와 결제 완료 상태를 확인하고 주문 상세 화면으로 이어집니다.',
      ),
      CustomerCoachTourStage.orderDetail => _buildTarget(
        id: 'customer.order.detail',
        key: CustomerDemoTargetKeys.orderTimeline,
        title: '주문 상세',
        description: '결제 이후 진행 상태와 배송 흐름을 이 화면에서 차례대로 확인할 수 있습니다.',
      ),
      CustomerCoachTourStage.returnRequest => _buildTarget(
        id: 'customer.return.request',
        key: CustomerDemoTargetKeys.returnRequestPrimaryAction,
        title: '반품 신청',
        description: '주문 상세 이후 반품 사유와 요청 금액을 작성해 반품 신청까지 이어지는 흐름입니다.',
        align: ContentAlign.top,
      ),
    };
  }

  TargetFocus? _buildTarget({
    required String id,
    required GlobalKey key,
    required String title,
    required String description,
    ContentAlign align = ContentAlign.bottom,
    CustomTargetContentPosition? customPosition,
  }) {
    if (key.currentContext == null) {
      return null;
    }

    return TargetFocus(
      identify: id,
      keyTarget: key,
      shape: ShapeLightFocus.RRect,
      radius: 14,
      enableOverlayTab: false,
      contents: [
        TargetContent(
          align: align,
          customPosition: customPosition,
          builder: (context, controller) {
            return _CoachTourBubble(
              title: title,
              description: description,
              isLast: _activeStage == CustomerCoachTourStage.returnRequest,
              onSkip: () {
                controller.skip();
                stop();
              },
              onNext: controller.next,
            );
          },
        ),
      ],
    );
  }

  CustomTargetContentPosition _homeQuickNavBubblePosition() {
    final context = AppRoutes.navigatorKey.currentContext;
    if (context == null) {
      return CustomTargetContentPosition(top: 420, right: 120);
    }

    final screenSize = MediaQuery.sizeOf(context);
    final top = (screenSize.height * 0.56).clamp(360.0, 520.0).toDouble();
    final right = screenSize.width < 700 ? 24.0 : 120.0;

    return CustomTargetContentPosition(top: top, right: right);
  }

  void _showStage(CustomerCoachTourStage stage, TargetFocus target) {
    _coachMark?.removeOverlayEntry();
    _coachMark = TutorialCoachMark(
      targets: [target],
      colorShadow: const Color(0xFF163B2B),
      opacityShadow: 0.18,
      paddingFocus: 14,
      hideSkip: true,
      pulseEnable: false,
      onSkip: () {
        stop();
        return true;
      },
      onFinish: () {
        _handleStageFinished(stage);
      },
      onClickOverlay: (_) {},
      onClickTarget: (_) {},
    )..showWithNavigatorStateKey(navigatorKey: AppRoutes.navigatorKey);
  }

  void _handleStageFinished(CustomerCoachTourStage stage) {
    switch (stage) {
      case CustomerCoachTourStage.signup:
        _activeStage = CustomerCoachTourStage.verifyEmail;
        AppRoutes.navigatorKey.currentState?.pushNamed(
          AppRoutes.verifyEmail,
          arguments: const SignupVerificationArgs(
            email: CustomerDemoRouteDefaults.demoSignupEmail,
            password: CustomerDemoRouteDefaults.demoSignupPassword,
            name: CustomerDemoRouteDefaults.demoSignupName,
            phone: CustomerDemoRouteDefaults.demoSignupPhone,
            emailAlreadySent: true,
          ),
        );
      case CustomerCoachTourStage.verifyEmail:
        _activeStage = CustomerCoachTourStage.login;
        AppRoutes.navigatorKey.currentState?.pushNamed(AppRoutes.login);
      case CustomerCoachTourStage.login:
        _activeStage = CustomerCoachTourStage.homeProductsCta;
        AppRoutes.navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.home,
          (route) => false,
        );
      case CustomerCoachTourStage.homeProductsCta:
        _activeStage = CustomerCoachTourStage.homeFeaturedCta;
      case CustomerCoachTourStage.homeFeaturedCta:
        _activeStage = CustomerCoachTourStage.homeQuickNav;
      case CustomerCoachTourStage.homeQuickNav:
        _activeStage = CustomerCoachTourStage.productList;
        AppRoutes.navigatorKey.currentState?.pushNamed(AppRoutes.products);
      case CustomerCoachTourStage.productList:
        _activeStage = CustomerCoachTourStage.productDetailPackage;
        AppRoutes.navigatorKey.currentState?.pushNamed(
          AppRoutes.productDetail,
          arguments: CustomerDemoRouteDefaults.featuredProductId,
        );
      case CustomerCoachTourStage.productDetailPackage:
        _activeStage = CustomerCoachTourStage.productDetailSlot;
      case CustomerCoachTourStage.productDetailSlot:
        _activeStage = CustomerCoachTourStage.productDetail;
      case CustomerCoachTourStage.productDetail:
        _primeDemoBasketItem();
        _activeStage = CustomerCoachTourStage.basket;
        AppRoutes.navigatorKey.currentState?.pushNamed(AppRoutes.basket);
      case CustomerCoachTourStage.basket:
        _activeStage = CustomerCoachTourStage.reservationConfirm;
        AppRoutes.navigatorKey.currentState?.pushNamed(
          AppRoutes.reservationConfirm,
        );
      case CustomerCoachTourStage.reservationConfirm:
        _activeStage = CustomerCoachTourStage.checkout;
        AppRoutes.navigatorKey.currentState?.pushNamed(
          AppRoutes.checkout,
          arguments: CustomerDemoRouteDefaults.checkoutReservationId,
        );
      case CustomerCoachTourStage.checkout:
        _activeStage = CustomerCoachTourStage.paymentMethod;
        AppRoutes.navigatorKey.currentState?.pushNamed(
          AppRoutes.payment,
          arguments: CustomerDemoRouteDefaults.paymentOrderId,
        );
      case CustomerCoachTourStage.paymentMethod:
        _activeStage = CustomerCoachTourStage.payment;
      case CustomerCoachTourStage.payment:
        _activeStage = CustomerCoachTourStage.orderComplete;
        AppRoutes.navigatorKey.currentState?.pushNamed(
          AppRoutes.orderComplete,
          arguments: CustomerDemoRouteDefaults.paymentOrderId,
        );
      case CustomerCoachTourStage.orderComplete:
        _activeStage = CustomerCoachTourStage.orderDetail;
        AppRoutes.navigatorKey.currentState?.pushNamed(
          AppRoutes.orderDetail,
          arguments: CustomerDemoRouteDefaults.deliveredOrderId,
        );
      case CustomerCoachTourStage.orderDetail:
        _activeStage = CustomerCoachTourStage.returnRequest;
        AppRoutes.navigatorKey.currentState?.pushNamed(
          AppRoutes.returnRequest,
          arguments: CustomerDemoRouteDefaults.deliveredOrderId,
        );
      case CustomerCoachTourStage.returnRequest:
        stop();
        return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 800), () {
        final mountedContext = AppRoutes.navigatorKey.currentContext;
        final activeStage = _activeStage;
        if (mountedContext == null ||
            !mountedContext.mounted ||
            activeStage == null) {
          return;
        }
        onPageReady(activeStage, mountedContext);
      });
    });
  }

  void _primeDemoBasketItem() {
    _localBasketRepository.replaceItems(CustomerDemoSeedData.demoBasketItems);
  }
}

class _CoachTourBubble extends StatelessWidget {
  const _CoachTourBubble({
    required this.title,
    required this.description,
    required this.isLast,
    required this.onSkip,
    required this.onNext,
  });

  final String title;
  final String description;
  final bool isLast;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final bubbleMaxWidth =
        (MediaQuery.sizeOf(context).width - 48).clamp(240.0, 420.0).toDouble();

    return UnconstrainedBox(
      constrainedAxis: Axis.vertical,
      child: SizedBox(
        width: bubbleMaxWidth,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A163B2B),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF163B2B),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                softWrap: true,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF4B584D),
                  height: 1.48,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: onSkip,
                    child: const Text('스킵'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: onNext,
                    child: Text(isLast ? '종료' : '다음'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
