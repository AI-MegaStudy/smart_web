import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/repository_contracts.dart';
import '../../data/repositories/return_repository.dart';

class ReturnRequestViewModel extends ChangeNotifier {
  ReturnRequestViewModel({
    required int orderId,
    OrderRepositoryContract? orderRepository,
    ReturnRepository? returnRepository,
  }) : _orderId = orderId,
       _orderRepository = orderRepository ?? OrderRepository(),
       _returnRepository = returnRepository ?? ReturnRepository();

  final int _orderId;
  final OrderRepositoryContract _orderRepository;
  final ReturnRepository _returnRepository;

  bool _isLoading = true;
  bool _isSubmitting = false;
  OrderModel? _order;
  ReturnRequestResult? _submittedReturn;
  String? _errorMessage;
  String reasonCode = 'QUALITY_ISSUE';
  String reasonDetail = '';

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  OrderModel? get order => _order;
  ReturnRequestResult? get submittedReturn => _submittedReturn;
  String? get errorMessage => _errorMessage;

  int get requestAmount {
    return _order?.totalAmount ?? 0;
  }

  List<String> get reasonLabels {
    return const ['상품 파손', '상품 변질', '오배송', '기타'];
  }

  String get selectedReasonLabel {
    return switch (reasonCode) {
      'DAMAGED' || 'QUALITY_ISSUE' => '상품 파손',
      'SPOILED' || 'FRESHNESS_ISSUE' => '상품 변질',
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
      '상품 파손' => 'QUALITY_ISSUE',
      '상품 변질' => 'FRESHNESS_ISSUE',
      '오배송' => 'WRONG_ITEM',
      _ => 'ETC',
    };
    _errorMessage = null;
    notifyListeners();
  }

  void updateReasonDetail(String value) {
    reasonDetail = value;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> submitReturnRequest() async {
    if (_isSubmitting) {
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _submittedReturn = await _returnRepository.createReturnRequest(
        orderId: _orderId,
        reasonCode: reasonCode,
        reasonDetail: reasonDetail.trim(),
        requestedAmount: requestAmount,
      );
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = '반품 요청을 접수하지 못했습니다. 잠시 후 다시 시도해주세요.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
