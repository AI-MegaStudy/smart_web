import '../../core/api/api_client.dart';
import '../../core/session/mock_auth_session.dart';
import '../../core/utils/order_status_mapper.dart';

class ReturnRequestResult {
  const ReturnRequestResult({
    required this.returnRequestId,
    required this.returnNumber,
    required this.returnStatusLabel,
    required this.orderId,
    required this.requestedAmount,
  });

  final int returnRequestId;
  final String returnNumber;
  final String returnStatusLabel;
  final int orderId;
  final int requestedAmount;
}

class ReturnHistoryItem {
  const ReturnHistoryItem({
    required this.returnRequestId,
    required this.orderId,
    required this.orderNumber,
    required this.returnNumber,
    required this.returnStatusLabel,
    required this.reasonLabel,
    required this.reasonDetail,
    required this.requestedAmount,
    required this.approvedAmount,
    required this.decisionReason,
    this.requestedAt,
    this.decidedAt,
  });

  final int returnRequestId;
  final int orderId;
  final String orderNumber;
  final String returnNumber;
  final String returnStatusLabel;
  final String reasonLabel;
  final String reasonDetail;
  final int requestedAmount;
  final int approvedAmount;
  final String decisionReason;
  final DateTime? requestedAt;
  final DateTime? decidedAt;
}

class ReturnRepository {
  ReturnRepository({ApiClient? apiClient})
    : _apiClient =
          apiClient ??
          ApiClient(
            accessTokenProvider: () async => MockAuthSession.accessToken,
          );

  final ApiClient _apiClient;

  Future<ReturnRequestResult> createReturnRequest({
    required int orderId,
    required String reasonCode,
    required String reasonDetail,
    required int requestedAmount,
    String? evidenceImageUrl,
  }) {
    return _apiClient.postData<ReturnRequestResult>(
      '/returns',
      requiresAuth: true,
      body: {
        'order_id': orderId,
        'reason_code': reasonCode,
        'reason_detail': reasonDetail,
        'evidence_image_url': evidenceImageUrl,
        'requested_amount': requestedAmount,
      },
      parser: (data) {
        final json = data as Map<String, dynamic>? ?? const {};
        return ReturnRequestResult(
          returnRequestId: _asInt(json['return_request_id']),
          returnNumber: json['return_no']?.toString() ?? '',
          returnStatusLabel: OrderStatusMapper.returnLabelOf(
            json['return_status']?.toString() ?? '',
          ),
          orderId: _asInt(json['order_id']),
          requestedAmount: _asInt(json['requested_amount']),
        );
      },
    );
  }

  Future<List<ReturnHistoryItem>> fetchMyReturns() {
    return _apiClient.getData<List<ReturnHistoryItem>>(
      '/me/returns',
      requiresAuth: true,
      parser: (data) {
        final rows = data as List<dynamic>? ?? const [];
        return rows
            .whereType<Map<String, dynamic>>()
            .map(_returnHistoryFromJson)
            .toList(growable: false);
      },
    );
  }

  static int _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static ReturnHistoryItem _returnHistoryFromJson(Map<String, dynamic> json) {
    return ReturnHistoryItem(
      returnRequestId: _asInt(json['return_request_id']),
      orderId: _asInt(json['order_id']),
      orderNumber: json['order_no']?.toString() ?? '',
      returnNumber: json['return_no']?.toString() ?? '',
      returnStatusLabel: OrderStatusMapper.returnLabelOf(
        json['return_status']?.toString() ?? '',
      ),
      reasonLabel: _reasonLabel(json['reason_code']?.toString() ?? ''),
      reasonDetail: json['reason_detail']?.toString() ?? '',
      requestedAmount: _asInt(json['requested_amount']),
      approvedAmount: _asInt(json['approved_amount']),
      decisionReason: json['decision_reason']?.toString() ?? '',
      requestedAt: _asDateTime(json['requested_at']),
      decidedAt: _asDateTime(json['decided_at']),
    );
  }

  static String _reasonLabel(String code) {
    switch (code) {
      case 'QUALITY_ISSUE':
      case 'DAMAGED':
        return '상품 파손';
      case 'FRESHNESS_ISSUE':
      case 'SPOILED':
        return '상품 변질';
      case 'WRONG_ITEM':
        return '오배송';
      case 'ETC':
        return '기타';
      default:
        return '사유 확인 중';
    }
  }

  static DateTime? _asDateTime(Object? value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }
}
