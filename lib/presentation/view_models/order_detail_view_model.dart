import 'package:flutter/foundation.dart';

import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

class OrderDetailViewModel extends ChangeNotifier {
  OrderDetailViewModel({required int orderId, OrderRepository? orderRepository})
    : _orderId = orderId,
      _orderRepository = orderRepository ?? OrderRepository();

  final int _orderId;
  final OrderRepository _orderRepository;

  bool _isLoading = true;
  OrderModel? _order;

  bool get isLoading => _isLoading;
  OrderModel? get order => _order;

  List<String> get progressLabels {
    return const ['결제 완료', '농가 확인 중', '농가 승인 완료', '배송 중', '배송 완료'];
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _order = await _orderRepository.fetchOrderDetail(_orderId);
    _isLoading = false;
    notifyListeners();
  }
}
