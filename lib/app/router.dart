import 'package:flutter/material.dart';

import '../presentation/views/home/home_page.dart';
import '../presentation/views/basket/local_basket_page.dart';
import '../presentation/views/checkout/checkout_page.dart';
import '../presentation/views/placeholders/coming_soon_page.dart';
import '../presentation/views/payment/mock_payment_page.dart';
import '../presentation/views/mypage/address_manage_page.dart';
import '../presentation/views/mypage/member_edit_page.dart';
import '../presentation/views/mypage/member_info_page.dart';
import '../presentation/views/mypage/my_page.dart';
import '../presentation/views/products/product_detail_page.dart';
import '../presentation/views/products/product_list_page.dart';
import '../presentation/views/reservation/reservation_confirm_page.dart';
import '../presentation/views/orders/order_complete_page.dart';
import '../presentation/views/orders/order_detail_page.dart';
import '../presentation/views/orders/my_orders_page.dart';
import '../presentation/views/returns/return_complete_page.dart';
import '../presentation/views/returns/return_request_page.dart';
import '../presentation/views/auth/signup_page.dart';
import '../presentation/views/auth/email_verify_page.dart';
import '../presentation/views/auth/login_page.dart';

class AppRoutes {
  static const home = '/';
  static const products = '/products';
  static const productDetail = '/products/detail';
  static const basket = '/basket';
  static const reservationConfirm = '/reservation/confirm';
  static const checkout = '/checkout';
  static const payment = '/payment';
  static const orderComplete = '/orders/complete';
  static const myPage = '/me';
  static const addressManage = '/me/addresses';
  static const addressAdd = '/me/addresses/add';
  static const memberInfo = '/me/profile';
  static const memberEdit = '/me/profile/edit';
  static const myOrders = '/me/orders';
  static const orderDetail = '/me/orders/detail';
  static const returnRequest = '/me/orders/return';
  static const returnComplete = '/me/orders/return/complete';
  static const login = '/login';
  static const signup = '/signup';
  static const verifyEmail = '/verify-email';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      home => const HomePage(),
      products => const ProductListPage(),
      productDetail => ProductDetailPage(
        productId: settings.arguments is int ? settings.arguments as int : 3,
      ),
      basket => const LocalBasketPage(),
      reservationConfirm => const ReservationConfirmPage(),
      checkout => CheckoutPage(
        reservationId: settings.arguments is int
            ? settings.arguments as int
            : 5,
      ),
      payment => MockPaymentPage(
        orderId: settings.arguments is int ? settings.arguments as int : 8,
      ),
      orderComplete => OrderCompletePage(
        orderId: settings.arguments is int ? settings.arguments as int : 8,
      ),
      myPage => const MyPage(),
      addressManage => const AddressManagePage(),
      addressAdd => AddressAddPage(isEdit: settings.arguments == 'edit'),
      memberInfo => const MemberInfoPage(),
      memberEdit => const MemberEditPage(),
      myOrders => const MyOrdersPage(),
      orderDetail => OrderDetailPage(
        orderId: settings.arguments is int ? settings.arguments as int : 8,
      ),
      returnRequest => ReturnRequestPage(
        orderId: settings.arguments is int ? settings.arguments as int : 8,
      ),
      returnComplete => ReturnCompletePage(
        orderId: settings.arguments is int ? settings.arguments as int : 8,
      ),
      login => const LoginPage(),
      signup => const SignupPage(),
      verifyEmail => const EmailVerifyPage(),
      _ => const ComingSoonPage(
        title: '준비 중',
        nextStep: '기획서 순서에 맞춰 화면을 하나씩 추가합니다.',
      ),
    };

    return MaterialPageRoute<void>(builder: (_) => page, settings: settings);
  }
}
