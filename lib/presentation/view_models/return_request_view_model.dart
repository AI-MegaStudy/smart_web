import 'package:flutter/foundation.dart';

import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/repository_contracts.dart';

class ReturnRequestViewModel extends ChangeNotifier {
  ReturnRequestViewModel({
    required int orderId,
    OrderRepositoryContract? orderRepository,
  }) : _orderId = orderId,
       _orderRepository = orderRepository ?? OrderRepository();

  final int _orderId;
  final OrderRepositoryContract _orderRepository;

  bool _isLoading = true;
  OrderModel? _order;
  String reasonCode = 'DAMAGED';
  String reasonDetail = '박스 외부 파손과 일부 사과 멍이 확인되었습니다.';

  bool get isLoading => _isLoading;
  OrderModel? get order => _order;

  int get requestAmount {
    return _order?.totalAmount ?? 0;
  }

  List<String> get reasonLabels {
    return const ['상품 파손', '상품 변질', '오배송', '기타'];
  }

  String get selectedReasonLabel {
    return switch (reasonCode) {
      'DAMAGED' => '상품 파손',
      'SPOILED' => '상품 변질',
      'WRONG_ITEM' => '오배송',
      _ => '기타',
    };
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _order = await _orderRepository.fetchOrderDetail(_orderId);
    _isLoading = false;
    notifyListeners();
  }

  void selectReason(String label) {
    reasonCode = switch (label) {
      '상품 파손' => 'DAMAGED',
      '상품 변질' => 'SPOILED',
      '오배송' => 'WRONG_ITEM',
      _ => 'ETC',
    };
    notifyListeners();
  }

  void updateReasonDetail(String value) {
    reasonDetail = value;
    notifyListeners();
  }

  Future<void> submitReturnRequest() async {
    await _orderRepository.requestReturn(_orderId);
  }
}
