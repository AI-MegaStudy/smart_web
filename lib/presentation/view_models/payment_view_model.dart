import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import '../../data/models/local_basket_item_model.dart';
import '../../data/repositories/local_basket_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/repository_contracts.dart';
import '../../demo/customer_coach_tour_manager.dart';
import '../../demo/customer_demo_seed_data.dart';

class PaymentViewModel extends ChangeNotifier {
  PaymentViewModel({
    required this.orderId,
    LocalBasketRepositoryContract? localBasketRepository,
    PaymentRepository? paymentRepository,
  }) : _localBasketRepository =
           localBasketRepository ?? LocalBasketRepository(),
       _paymentRepository = paymentRepository ?? PaymentRepository();

  final int orderId;
  final LocalBasketRepositoryContract _localBasketRepository;
  final PaymentRepository _paymentRepository;

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  List<LocalBasketItemModel> _items = const [];

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  List<LocalBasketItemModel> get items => _items;

  int get totalAmount {
    return _items.fold(0, (sum, item) => sum + item.subtotalAmount);
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    if (CustomerCoachTourManager.instance.isDemoMode) {
      _items = OrderPaymentCache.itemsFor(orderId);
      if (_items.isEmpty) {
        _items = CustomerDemoSeedData.demoBasketItems;
      }
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final orderItems = OrderPaymentCache.itemsFor(orderId);
      _items = orderItems.isNotEmpty
          ? orderItems
          : await _localBasketRepository.fetchItems();
    } catch (_) {
      _items = const [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> approvePayment() async {
    if (CustomerCoachTourManager.instance.isDemoMode) {
      _localBasketRepository.replaceItems(const []);
      return true;
    }

    if (_isSubmitting) {
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _paymentRepository.mockApprove(
        orderId: orderId,
        idempotencyKey: 'payment-order-$orderId-mock-approve',
      );
      _localBasketRepository.replaceItems(const []);
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = '결제를 완료하지 못했습니다.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
