import 'package:flutter/material.dart';

import '../view/pages/home_page.dart';
import '../view/pages/product_list_page.dart';
import '../view/pages/product_detail_page.dart';
import '../view/pages/cart_page.dart';
import '../view/pages/signup_page.dart';
import '../view/pages/login_page.dart';
import '../view/pages/order_form_page.dart';
import '../view/pages/payment_page.dart';
import '../view/pages/order_success_page.dart';
import '../view/pages/order_history_page.dart';
import '../view/pages/reservation_form_page.dart';
import '../view/pages/reservation_status_page.dart';
import '../view/pages/review_page.dart';
import '../view/pages/admin_product_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (_) => const HomePage(),
    '/products': (_) => const ProductListPage(),
    '/product-detail': (_) => const ProductDetailPage(),
    '/cart': (_) => const CartPage(),
    '/signup': (_) => const SignupPage(),
    '/login': (_) => const LoginPage(),
    '/order-form': (_) => const OrderFormPage(),
    '/payment': (_) => const PaymentPage(),
    '/order-success': (_) => const OrderSuccessPage(),
    '/orders': (_) => const OrderHistoryPage(),
    '/reservation-form': (_) => const ReservationFormPage(),
    '/reservation-status': (_) => const ReservationStatusPage(),
    '/review': (_) => const ReviewPage(),
    '/admin-product': (_) => const AdminProductPage(),
  };
}
