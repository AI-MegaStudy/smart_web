import '../../core/api/api_client.dart';
import '../../core/session/mock_auth_session.dart';
import '../../core/utils/order_status_mapper.dart';
import '../models/local_basket_item_model.dart';
import '../models/order_model.dart';
import 'repository_contracts.dart';

class OrderCreateResult {
  const OrderCreateResult({
    required this.orderId,
    required this.orderNo,
    required this.orderStatus,
    required this.totalAmount,
  });

  final int orderId;
  final String orderNo;
  final String orderStatus;
  final int totalAmount;
}

class OrderPaymentCache {
  OrderPaymentCache._();

  static final Map<int, List<LocalBasketItemModel>> _itemsByOrderId = {};

  static void save(int orderId, List<LocalBasketItemModel> items) {
    _itemsByOrderId[orderId] = List.unmodifiable(items);
  }

  static List<LocalBasketItemModel> itemsFor(int orderId) {
    return _itemsByOrderId[orderId] ?? const [];
  }
}

class OrderRepository implements OrderRepositoryContract {
  OrderRepository({ApiClient? apiClient})
    : _apiClient =
          apiClient ??
          ApiClient(
            accessTokenProvider: () async => MockAuthSession.accessToken,
          );

  final ApiClient _apiClient;
  static final Set<int> _returnRequestedOrderIds = {};

  Future<OrderCreateResult> createFromReservation({
    required int reservationId,
    required String receiverName,
    required String receiverPhone,
    required String shippingAddress,
    required String deliveryMemo,
  }) {
    return _apiClient.postData<OrderCreateResult>(
      '/orders/from-reservation',
      requiresAuth: true,
      body: {
        'reservation_id': reservationId,
        'receiver_name': receiverName,
        'receiver_phone': receiverPhone,
        'shipping_address': shippingAddress,
        'delivery_memo': deliveryMemo,
      },
      parser: (data) {
        final json = data as Map<String, dynamic>? ?? const {};
        return OrderCreateResult(
          orderId: _asInt(json['order_id']),
          orderNo: json['order_no']?.toString() ?? '',
          orderStatus: json['order_status']?.toString() ?? '',
          totalAmount: _asInt(json['total_amount']),
        );
      },
    );
  }

  @override
  Future<List<OrderModel>> fetchOrders() {
    return _apiClient.getData<List<OrderModel>>(
      '/me/orders',
      requiresAuth: true,
      parser: (data) {
        final rows = data as List<dynamic>? ?? const [];
        return rows
            .whereType<Map<String, dynamic>>()
            .map(_orderFromJson)
            .toList(growable: false);
      },
    );
  }

  @override
  Future<OrderModel> fetchOrderDetail(int orderId) {
    return _apiClient.getData<OrderModel>(
      '/me/orders/$orderId',
      requiresAuth: true,
      parser: (data) =>
          _orderFromJson(data as Map<String, dynamic>? ?? const {}),
    );
  }

  @override
  Future<void> requestReturn(int orderId) async {
    _returnRequestedOrderIds.add(orderId);
  }

  static OrderModel _orderFromJson(Map<String, dynamic> json) {
    final rawItems = json['order_items'] as List<dynamic>? ?? const [];
    return OrderModel(
      orderId: _asInt(json['order_id']),
      orderNumber: json['order_no']?.toString() ?? '',
      orderStatusLabel: OrderStatusMapper.labelOf(
        json['order_status']?.toString() ?? '',
      ),
      receiverName: json['receiver_name']?.toString() ?? '',
      shippingAddress: json['shipping_address']?.toString() ?? '',
      carrierName: '배송 준비 중',
      trackingNumber: json['tracking_no']?.toString() ?? '',
      orderedAt: _asDateTime(json['ordered_at']),
      paidAt: _asDateTime(json['paid_at']),
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(_orderItemFromJson)
          .toList(growable: false),
    );
  }

  static LocalBasketItemModel _orderItemFromJson(Map<String, dynamic> json) {
    final packageCount = _asInt(json['package_count']);
    final orderedKg = _asDouble(json['ordered_kg']);
    final packageUnitKg = packageCount == 0 ? 0.0 : orderedKg / packageCount;
    return LocalBasketItemModel(
      slotId: _asInt(json['slot_id']),
      productId: _asInt(json['product_id']),
      productName: _productName(json),
      farmName: json['farm_name']?.toString() ?? '농장 정보 확인 중',
      harvestStartLabel: '',
      harvestEndLabel: '',
      packageUnitKg: packageUnitKg,
      unitPrice: _asInt(json['unit_price']),
      packageCount: packageCount,
    );
  }

  static String _productName(Map<String, dynamic> json) {
    final rawName = json['product_name']?.toString() ?? '예약 상품';
    final displayName = rawName
        .replaceAll(RegExp(r'\s*\d+(\.\d+)?kg'), '')
        .trim();

    if (displayName == '예약 사과') {
      return '부사 사과';
    }
    if (displayName == '예약 배') {
      return '신고 사과';
    }
    if (displayName.startsWith('예약 ')) {
      return displayName.replaceFirst('예약 ', '');
    }

    return displayName.isEmpty ? '예약 상품' : displayName;
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

  static double _asDouble(Object? value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _asDateTime(Object? value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }
}
