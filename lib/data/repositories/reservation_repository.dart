import '../../core/api/api_client.dart';
import '../../core/session/mock_auth_session.dart';
import '../models/local_basket_item_model.dart';

class ReservationCreateResult {
  const ReservationCreateResult({
    required this.reservationId,
    required this.reservationNo,
    required this.reservationStatus,
    required this.totalReservedKg,
    required this.totalAmount,
  });

  final int reservationId;
  final String reservationNo;
  final String reservationStatus;
  final double totalReservedKg;
  final int totalAmount;
}

class ReservationPreviewResult {
  const ReservationPreviewResult({
    required this.items,
    required this.totalReservedKg,
    required this.totalAmount,
  });

  final List<ReservationPreviewItem> items;
  final double totalReservedKg;
  final int totalAmount;
}

class ReservationPreviewItem {
  const ReservationPreviewItem({
    required this.slotId,
    required this.packageCount,
    required this.reservedKg,
    required this.unitPriceSnapshot,
    required this.subtotalAmount,
    required this.availableKg,
  });

  final int slotId;
  final int packageCount;
  final double reservedKg;
  final int unitPriceSnapshot;
  final int subtotalAmount;
  final double availableKg;
}

class ReservationCheckoutCache {
  ReservationCheckoutCache._();

  static final Map<int, List<LocalBasketItemModel>> _itemsByReservationId = {};

  static void save(int reservationId, List<LocalBasketItemModel> items) {
    _itemsByReservationId[reservationId] = List.unmodifiable(items);
  }

  static List<LocalBasketItemModel> itemsFor(int reservationId) {
    return _itemsByReservationId[reservationId] ?? const [];
  }
}

class ReservationRepository {
  ReservationRepository({ApiClient? apiClient})
    : _apiClient =
          apiClient ??
          ApiClient(
            accessTokenProvider: () async => MockAuthSession.accessToken,
          );

  final ApiClient _apiClient;

  Future<ReservationPreviewResult> preview(List<LocalBasketItemModel> items) {
    return _apiClient.postData<ReservationPreviewResult>(
      '/reservations/preview',
      body: {
        'items': [
          for (final item in items)
            {'slot_id': item.slotId, 'package_count': item.packageCount},
        ],
      },
      parser: (data) {
        final json = data as Map<String, dynamic>? ?? const {};
        final rawItems = json['items'] as List<dynamic>? ?? const [];
        return ReservationPreviewResult(
          items: rawItems
              .whereType<Map<String, dynamic>>()
              .map(_previewItemFromJson)
              .toList(growable: false),
          totalReservedKg: _asDouble(json['total_reserved_kg']),
          totalAmount: _asInt(json['total_amount']),
        );
      },
    );
  }

  Future<ReservationCreateResult> create(List<LocalBasketItemModel> items) {
    return _apiClient.postData<ReservationCreateResult>(
      '/reservations',
      requiresAuth: true,
      body: {
        'items': [
          for (final item in items)
            {'slot_id': item.slotId, 'package_count': item.packageCount},
        ],
      },
      parser: (data) {
        final json = data as Map<String, dynamic>? ?? const {};
        return ReservationCreateResult(
          reservationId: _asInt(json['reservation_id']),
          reservationNo: json['reservation_no']?.toString() ?? '',
          reservationStatus: json['reservation_status']?.toString() ?? '',
          totalReservedKg: _asDouble(json['total_reserved_kg']),
          totalAmount: _asInt(json['total_amount']),
        );
      },
    );
  }

  static ReservationPreviewItem _previewItemFromJson(
    Map<String, dynamic> json,
  ) {
    return ReservationPreviewItem(
      slotId: _asInt(json['slot_id']),
      packageCount: _asInt(json['package_count']),
      reservedKg: _asDouble(json['reserved_kg']),
      unitPriceSnapshot: _asInt(json['unit_price_snapshot']),
      subtotalAmount: _asInt(json['subtotal_amount']),
      availableKg: _asDouble(json['available_kg']),
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

  static double _asDouble(Object? value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
