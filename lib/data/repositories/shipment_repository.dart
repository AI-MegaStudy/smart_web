import '../../core/api/api_client.dart';
import '../../core/session/mock_auth_session.dart';
import '../../core/utils/order_status_mapper.dart';

class ShipmentInfo {
  const ShipmentInfo({
    required this.carrierName,
    required this.trackingNumber,
    required this.shipmentStatusLabel,
    this.shippedAt,
    this.deliveredAt,
  });

  final String carrierName;
  final String trackingNumber;
  final String shipmentStatusLabel;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;

  bool get hasTrackingInfo {
    return carrierName.isNotEmpty && trackingNumber.isNotEmpty;
  }
}

class ShipmentRepository {
  ShipmentRepository({ApiClient? apiClient})
    : _apiClient =
          apiClient ??
          ApiClient(
            accessTokenProvider: () async => MockAuthSession.accessToken,
          );

  final ApiClient _apiClient;

  Future<ShipmentInfo> fetchOrderShipment(int orderId) {
    return _apiClient.getData<ShipmentInfo>(
      '/me/orders/$orderId/shipment',
      requiresAuth: true,
      parser: (data) {
        final json = data as Map<String, dynamic>? ?? const {};
        return ShipmentInfo(
          carrierName: json['carrier_name']?.toString() ?? '',
          trackingNumber: json['tracking_no']?.toString() ?? '',
          shipmentStatusLabel: OrderStatusMapper.shipmentLabelOf(
            json['shipment_status']?.toString() ?? '',
          ),
          shippedAt: _asDateTime(json['shipped_at']),
          deliveredAt: _asDateTime(json['delivered_at']),
        );
      },
    );
  }

  static DateTime? _asDateTime(Object? value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }
}
