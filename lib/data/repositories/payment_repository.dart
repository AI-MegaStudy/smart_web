import '../../core/api/api_client.dart';
import '../../core/session/mock_auth_session.dart';

class PaymentApproveResult {
  const PaymentApproveResult({
    required this.paymentId,
    required this.paymentStatus,
    required this.approvedAmount,
    required this.orderStatus,
    required this.procurementId,
  });

  final int paymentId;
  final String paymentStatus;
  final int approvedAmount;
  final String orderStatus;
  final int procurementId;
}

class PaymentHistoryItem {
  const PaymentHistoryItem({
    required this.paymentStatusLabel,
    required this.paymentMethodLabel,
    required this.requestedAmount,
    required this.approvedAmount,
  });

  final String paymentStatusLabel;
  final String paymentMethodLabel;
  final int requestedAmount;
  final int approvedAmount;
}

class PaymentRepository {
  PaymentRepository({ApiClient? apiClient})
    : _apiClient =
          apiClient ??
          ApiClient(
            accessTokenProvider: () async => MockAuthSession.accessToken,
          );

  final ApiClient _apiClient;

  Future<List<PaymentHistoryItem>> fetchOrderPayments(int orderId) {
    return _apiClient.getData<List<PaymentHistoryItem>>(
      '/me/orders/$orderId/payments',
      requiresAuth: true,
      parser: (data) {
        final items = data as List<dynamic>? ?? const [];
        return items
            .map((item) {
              final json = item as Map<String, dynamic>? ?? const {};
              return PaymentHistoryItem(
                paymentStatusLabel: _statusLabel(
                  json['payment_status']?.toString() ?? '',
                ),
                paymentMethodLabel: _methodLabel(
                  json['payment_method']?.toString() ?? '',
                ),
                requestedAmount: _asInt(json['requested_amount']),
                approvedAmount: _asInt(json['approved_amount']),
              );
            })
            .toList(growable: false);
      },
    );
  }

  Future<PaymentApproveResult> mockApprove({
    required int orderId,
    required String idempotencyKey,
  }) {
    return _apiClient.postData<PaymentApproveResult>(
      '/payments/mock-approve',
      requiresAuth: true,
      body: {'order_id': orderId, 'idempotency_key': idempotencyKey},
      parser: (data) {
        final json = data as Map<String, dynamic>? ?? const {};
        return PaymentApproveResult(
          paymentId: _asInt(json['payment_id']),
          paymentStatus: json['payment_status']?.toString() ?? '',
          approvedAmount: _asInt(json['approved_amount']),
          orderStatus: json['order_status']?.toString() ?? '',
          procurementId: _asInt(json['procurement_id']),
        );
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

  static String _statusLabel(String status) {
    switch (status) {
      case 'APPROVED':
        return '결제 완료';
      case 'PENDING':
      case 'REQUESTED':
        return '결제 대기';
      case 'FAILED':
        return '결제 실패';
      case 'CANCELED':
      case 'CANCELLED':
        return '결제 취소';
      case 'REFUNDED':
        return '환불 완료';
      default:
        return '결제 상태 확인 중';
    }
  }

  static String _methodLabel(String method) {
    switch (method) {
      case 'MOCK_CARD':
      case 'CARD':
        return '카드 결제';
      case 'BANK_TRANSFER':
        return '계좌이체';
      case 'VIRTUAL_ACCOUNT':
        return '가상계좌';
      default:
        return '카드 결제';
    }
  }
}
