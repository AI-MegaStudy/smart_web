import 'package:flutter/material.dart';

class CustomerDemoTargetKeys {
  static final signupPrimaryAction = GlobalKey(
    debugLabel: 'demo.customer.signup.primary.action',
  );
  static final verifyEmailPrimaryAction = GlobalKey(
    debugLabel: 'demo.customer.verify.email.primary.action',
  );
  static final loginPrimaryAction = GlobalKey(
    debugLabel: 'demo.customer.login.primary.action',
  );
  static final homeProductsButton = GlobalKey(
    debugLabel: 'demo.customer.home.products.button',
  );
  static final homeFeaturedButton = GlobalKey(
    debugLabel: 'demo.customer.home.featured.button',
  );
  static final homeQuickNav = GlobalKey(
    debugLabel: 'demo.customer.home.quick.nav',
  );
  static final homeProducts = GlobalKey(
    debugLabel: 'demo.customer.home.products',
  );
  static final productListFirstCard = GlobalKey(
    debugLabel: 'demo.customer.product.list.first.card',
  );
  static final productDetailPackageSelector = GlobalKey(
    debugLabel: 'demo.customer.product.detail.package.selector',
  );
  static final productDetailSlotSelector = GlobalKey(
    debugLabel: 'demo.customer.product.detail.slot.selector',
  );
  static final productDetailAddToBasket = GlobalKey(
    debugLabel: 'demo.customer.product.detail.add.to.basket',
  );
  static final basketPrimaryAction = GlobalKey(
    debugLabel: 'demo.customer.basket.primary.action',
  );
  static final reservationConfirmPrimaryAction = GlobalKey(
    debugLabel: 'demo.customer.reservation.confirm.primary.action',
  );
  static final checkoutPrimaryAction = GlobalKey(
    debugLabel: 'demo.customer.checkout.primary.action',
  );
  static final paymentMethodSelector = GlobalKey(
    debugLabel: 'demo.customer.payment.method.selector',
  );
  static final paymentPrimaryAction = GlobalKey(
    debugLabel: 'demo.customer.payment.primary.action',
  );
  static final orderCompletePrimaryAction = GlobalKey(
    debugLabel: 'demo.customer.order.complete.primary.action',
  );
  static final orderTimeline = GlobalKey(
    debugLabel: 'demo.customer.order.detail.timeline',
  );
  static final returnRequestPrimaryAction = GlobalKey(
    debugLabel: 'demo.customer.return.request.primary.action',
  );

  const CustomerDemoTargetKeys._();
}
