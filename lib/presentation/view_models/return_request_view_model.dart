import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/repository_contracts.dart';
import '../../data/repositories/return_repository.dart';
import '../../demo/customer_coach_tour_manager.dart';
import '../../demo/customer_demo_order_data.dart';
import '../../demo/customer_demo_return_data.dart';

class ReturnEvidenceImage {
  const ReturnEvidenceImage({
    required this.fileName,
    required this.previewUrl,
    required this.storageUrl,
  });

  final String fileName;
  final String previewUrl;
  final String storageUrl;
}

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
  bool _isCustomAmount = false;
  int? _customRequestAmount;
  final List<ReturnEvidenceImage> _evidenceImages = [];

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  OrderModel? get order => _order;
  ReturnRequestResult? get submittedReturn => _submittedReturn;
  String? get errorMessage => _errorMessage;
  bool get isCustomAmount => _isCustomAmount;
  List<ReturnEvidenceImage> get evidenceImages =>
      List.unmodifiable(_evidenceImages);
  bool get hasEvidenceImage => _evidenceImages.isNotEmpty;
  int get evidenceImageCount => _evidenceImages.length;
  String get evidenceSummaryLabel {
    if (_evidenceImages.isEmpty) {
      return '선택 전';
    }
    return '${_evidenceImages.length}장 선택';
  }

  String? get evidenceImageUrl {
    if (_evidenceImages.isEmpty) {
      return null;
    }
    return _evidenceImages.map((image) => image.storageUrl).join(',');
  }

  int get maxRequestAmount => _order?.totalAmount ?? 0;

  int get requestAmount {
    if (!_isCustomAmount) {
      return maxRequestAmount;
    }
    final amount = _customRequestAmount ?? 0;
    if (amount < 0) {
      return 0;
    }
    if (amount > maxRequestAmount) {
      return maxRequestAmount;
    }
    return amount;
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

    if (CustomerCoachTourManager.instance.isDemoMode) {
      _order =
          CustomerDemoOrderData.orderById(_orderId) ??
          CustomerDemoOrderData.orderById(26);
      reasonCode = 'QUALITY_ISSUE';
      reasonDetail =
          '사과 일부가 눌려 있었고 표면 상태가 기대와 달라 반품을 요청합니다. 증빙 사진도 함께 첨부했습니다.';
      _isCustomAmount = false;
      _customRequestAmount = null;
      _evidenceImages
        ..clear()
        ..addAll(const [
          ReturnEvidenceImage(
            fileName: 'apple_damage_01.jpg',
            previewUrl:
                'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?auto=format&fit=crop&w=800&q=80',
            storageUrl:
                'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?auto=format&fit=crop&w=800&q=80',
          ),
          ReturnEvidenceImage(
            fileName: 'apple_damage_02.jpg',
            previewUrl:
                'https://images.unsplash.com/photo-1570913149827-d2ac84ab3f9a?auto=format&fit=crop&w=800&q=80',
            storageUrl:
                'https://images.unsplash.com/photo-1570913149827-d2ac84ab3f9a?auto=format&fit=crop&w=800&q=80',
          ),
        ]);
      _isLoading = false;
      notifyListeners();
      return;
    }

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

  void selectFullAmount() {
    _isCustomAmount = false;
    _customRequestAmount = null;
    _errorMessage = null;
    notifyListeners();
  }

  void selectCustomAmount() {
    _isCustomAmount = true;
    _customRequestAmount ??= maxRequestAmount;
    _errorMessage = null;
    notifyListeners();
  }

  void updateCustomRequestAmount(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    _customRequestAmount = int.tryParse(digits) ?? 0;
    _errorMessage = null;
    notifyListeners();
  }

  void attachEvidenceImages(
    List<({String fileName, String previewUrl})> images,
  ) {
    _evidenceImages
      ..clear()
      ..addAll(
        images.map((image) {
          final safeFileName = image.fileName.replaceAll(
            RegExp(r'[^A-Za-z0-9._-]'),
            '_',
          );
          return ReturnEvidenceImage(
            fileName: image.fileName,
            previewUrl: image.previewUrl,
            storageUrl: '/returns/evidence/$safeFileName',
          );
        }),
      );
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> submitReturnRequest() async {
    if (CustomerCoachTourManager.instance.isDemoMode) {
      _submittedReturn = CustomerDemoReturnData.submittedResult(
        orderId: _orderId,
        requestedAmount: requestAmount,
      );
      return true;
    }

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
        evidenceImageUrl: evidenceImageUrl,
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
