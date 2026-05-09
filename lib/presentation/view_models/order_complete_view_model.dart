import 'package:flutter/foundation.dart';

import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/repository_contracts.dart';

class OrderCompleteViewModel extends ChangeNotifier {
  OrderCompleteViewModel({
    required this.orderId,
    OrderRepositoryContract? orderRepository,
  }) : _orderRepository = orderRepository ?? OrderRepository();

  final int orderId;
  final OrderRepositoryContract _orderRepository;

  bool _isLoading = true;
  String? _errorMessage;
  OrderModel? _order;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  OrderModel? get order => _order;

  String get orderNumber {
    return _order?.orderNumber ?? 'ORD-${orderId.toString().padLeft(3, '0')}';
  }

  String get statusLabel {
    return _order?.orderStatusLabel ?? '상태 확인 중';
  }

  int get totalAmount {
    return _order?.totalAmount ?? 0;
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _order = await _orderRepository.fetchOrderDetail(orderId);
    } catch (_) {
      _order = null;
      _errorMessage = '주문 정보를 불러오지 못했습니다.';
    }

    _isLoading = false;
    notifyListeners();
  }
}
