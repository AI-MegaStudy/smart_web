import 'package:flutter/foundation.dart';

import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/repository_contracts.dart';
import '../../demo/customer_coach_tour_manager.dart';
import '../../demo/customer_demo_order_data.dart';

class MyOrdersViewModel extends ChangeNotifier {
  MyOrdersViewModel({OrderRepositoryContract? orderRepository})
    : _orderRepository = orderRepository ?? OrderRepository();

  final OrderRepositoryContract _orderRepository;

  bool _isLoading = true;
  String? _errorMessage;
  List<OrderModel> _orders = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<OrderModel> get orders => _orders;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (CustomerCoachTourManager.instance.isDemoMode) {
      _orders = CustomerDemoOrderData.orders();
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _orders = await _orderRepository.fetchOrders();
    } catch (_) {
      _orders = const [];
      _errorMessage = '주문 내역을 불러오지 못했습니다. 잠시 후 다시 확인해주세요.';
    }

    _isLoading = false;
    notifyListeners();
  }
}
