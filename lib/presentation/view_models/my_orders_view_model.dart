import 'package:flutter/foundation.dart';

import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

class MyOrdersViewModel extends ChangeNotifier {
  MyOrdersViewModel({OrderRepository? orderRepository})
    : _orderRepository = orderRepository ?? OrderRepository();

  final OrderRepository _orderRepository;

  bool _isLoading = true;
  List<OrderModel> _orders = const [];

  bool get isLoading => _isLoading;
  List<OrderModel> get orders => _orders;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _orders = await _orderRepository.fetchOrders();
    _isLoading = false;
    notifyListeners();
  }
}
