import '../../core/api/api_client.dart';
import '../models/harvest_slot_model.dart';
import '../models/product_model.dart';
import 'repository_contracts.dart';

class ProductApiRepository implements ProductRepositoryContract {
  ProductApiRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<List<ProductModel>> fetchProducts() async {
    final products = await _apiClient.getData<List<Map<String, dynamic>>>(
      '/products',
      parser: _parseProductMaps,
    );
    return Future.wait(products.map(_productWithFirstSlotFromJson));
  }

  @override
  Future<List<ProductModel>> fetchFeaturedProducts() async {
    final products = await _apiClient.getData<List<Map<String, dynamic>>>(
      '/products',
      queryParameters: const {'featured': 'true'},
      parser: _parseProductMaps,
    );
    return Future.wait(products.map(_productWithFirstSlotFromJson));
  }

  @override
  Future<ProductModel> fetchProductDetail(int productId) async {
    final product = await _apiClient.getData<Map<String, dynamic>>(
      '/products/$productId',
      parser: (data) => data as Map<String, dynamic>,
    );
    final slots = await fetchProductSlots(productId);
    return _productFromJson(
      product,
      slots.isEmpty ? null : slots.first,
      slots.length,
    );
  }

  @override
  Future<List<HarvestSlotModel>> fetchProductSlots(int productId) {
    return _apiClient.getData<List<HarvestSlotModel>>(
      '/products/$productId/slots',
      parser: _parseSlots,
    );
  }

  List<Map<String, dynamic>> _parseProductMaps(Object? data) {
    final items = data as List<dynamic>? ?? const [];
    return items.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  Future<ProductModel> _productWithFirstSlotFromJson(
    Map<String, dynamic> json,
  ) async {
    final productId = _asInt(json['product_id']);
    final slots = await fetchProductSlots(productId);
    return _productFromJson(
      json,
      slots.isEmpty ? null : slots.first,
      slots.length,
    );
  }

  List<HarvestSlotModel> _parseSlots(Object? data) {
    final items = data as List<dynamic>? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(_slotFromJson)
        .toList(growable: false);
  }

  ProductModel _productFromJson(
    Map<String, dynamic> json, [
    HarvestSlotModel? firstSlot,
    int? fetchedOpenSlotCount,
  ]) {
    final openSlotCount =
        fetchedOpenSlotCount ?? _asInt(json['open_slot_count']);
    return ProductModel(
      productId: _asInt(json['product_id']),
      name: _productName(json),
      farmName: json['farm_name']?.toString() ?? '농장 정보 확인 중',
      variety: _varietyName(json['variety']),
      packageUnitKg: _asDouble(json['package_unit_kg']),
      price:
          firstSlot?.confirmedPrice ??
          _asInt(json['min_open_slot_price'] ?? json['base_price']),
      harvestStartLabel: firstSlot?.harvestStartLabel ?? '',
      harvestEndLabel: firstSlot?.harvestEndLabel ?? '',
      availableKg: firstSlot?.availableKg ?? _asDouble(json['available_kg']),
      imageUrl: _imageUrl(json['image_url']),
      openSlotCount: firstSlot == null
          ? openSlotCount
          : openSlotCount < 1
          ? 1
          : openSlotCount,
    );
  }

  HarvestSlotModel _slotFromJson(Map<String, dynamic> json) {
    return HarvestSlotModel(
      slotId: _asInt(json['slot_id']),
      productId: _asInt(json['product_id']),
      harvestStartLabel: _dateLabel(json['confirmed_harvest_start']),
      harvestEndLabel: _dateLabel(json['confirmed_harvest_end']),
      confirmedPrice: _asInt(json['confirmed_price']),
      confirmedReservableKg: _asDouble(json['confirmed_reservable_kg']),
      availableKg: _asDouble(json['available_kg']),
      customerNotice:
          json['customer_notice']?.toString() ??
          '수확 일정은 기상과 생육 상황에 따라 조정될 수 있습니다.',
      slotStatus: json['slot_status']?.toString() ?? 'OPEN',
    );
  }

  String _productName(Map<String, dynamic> json) {
    final name = json['product_name']?.toString() ?? '예약 사과';
    final displayName = name.replaceAll(RegExp(r'\s*\d+(\.\d+)?kg'), '').trim();
    final variety = _varietyName(json['variety']);
    final fruit = _fruitName(json['fruit_type'], displayName);

    if (variety.isNotEmpty && fruit.isNotEmpty) {
      return '$variety $fruit';
    }

    return displayName.isEmpty ? '예약 사과' : displayName;
  }

  String _varietyName(Object? value) {
    final raw = value?.toString().trim();
    return switch (raw?.toLowerCase()) {
      'fuji' => '부사',
      'yanggwang' || 'yangkwang' => '신고',
      'shingo' => '신고',
      null || '' => '사과',
      _ => raw!,
    };
  }

  String _fruitName(Object? fruitType, String displayName) {
    final raw = fruitType?.toString().trim().toLowerCase();
    return switch (raw) {
      'apple' => '사과',
      'pear' => '배',
      _ when displayName.contains('사과') => '사과',
      _ when displayName.contains('배') => '배',
      _ => '',
    };
  }

  String _dateLabel(Object? value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) {
      return '';
    }

    final date = DateTime.tryParse(raw);
    if (date == null) {
      return raw;
    }
    return '${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  String _imageUrl(Object? value) {
    final url = value?.toString();
    if (url == null || url.isEmpty) {
      return 'https://images.unsplash.com/photo-1570913149827-d2ac84ab3f9a?auto=format&fit=crop&w=900&q=80';
    }
    return url;
  }

  int _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _asDouble(Object? value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
