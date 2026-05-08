import '../models/harvest_slot_model.dart';
import '../models/product_model.dart';
import 'repository_contracts.dart';

class ProductRepository implements ProductRepositoryContract {
  @override
  Future<List<ProductModel>> fetchProducts() async {
    return _products;
  }

  @override
  Future<ProductModel> fetchProductDetail(int productId) async {
    return _products.firstWhere((product) => product.productId == productId);
  }

  @override
  Future<List<HarvestSlotModel>> fetchProductSlots(int productId) async {
    return _slots
        .where((slot) => slot.productId == productId)
        .toList(growable: false);
  }

  @override
  Future<List<ProductModel>> fetchFeaturedProducts() async {
    return _products.take(3).toList(growable: false);
  }
}

const _products = [
  ProductModel(
    productId: 3,
    name: '양광 사과',
    farmName: '충주 햇살농원',
    variety: '양광',
    packageUnitKg: 5,
    price: 39000,
    harvestStartLabel: '10.12',
    harvestEndLabel: '10.18',
    availableKg: 185,
    imageUrl:
        'https://images.unsplash.com/photo-1570913149827-d2ac84ab3f9a?auto=format&fit=crop&w=900&q=80',
  ),
  ProductModel(
    productId: 4,
    name: '부사 사과',
    farmName: '문경 바람농장',
    variety: '부사',
    packageUnitKg: 3,
    price: 32000,
    harvestStartLabel: '10.20',
    harvestEndLabel: '10.27',
    availableKg: 42,
    imageUrl:
        'https://images.unsplash.com/photo-1568702846914-96b305d2aaeb?auto=format&fit=crop&w=900&q=80',
  ),
  ProductModel(
    productId: 5,
    name: '양광 사과',
    farmName: '영주 별빛과수원',
    variety: '양광',
    packageUnitKg: 7.5,
    price: 68000,
    harvestStartLabel: '09.28',
    harvestEndLabel: '10.04',
    availableKg: 75,
    imageUrl:
        'https://images.unsplash.com/photo-1579613832125-5d34a13ffe2a?auto=format&fit=crop&w=900&q=80',
  ),
  ProductModel(
    productId: 6,
    name: '부사 사과',
    farmName: '충주 온빛농장',
    variety: '부사',
    packageUnitKg: 5,
    price: 56000,
    harvestStartLabel: '10.05',
    harvestEndLabel: '10.11',
    availableKg: 20,
    imageUrl:
        'https://images.unsplash.com/photo-1600423115367-87ea7661688f?auto=format&fit=crop&w=900&q=80',
  ),
];

const _slots = [
  HarvestSlotModel(
    slotId: 12,
    productId: 3,
    harvestStartLabel: '10.12',
    harvestEndLabel: '10.18',
    confirmedPrice: 39000,
    confirmedReservableKg: 300,
    availableKg: 185,
    customerNotice: '수확 예정 범위는 기상 상황에 따라 조정될 수 있습니다.',
    slotStatus: 'OPEN',
  ),
  HarvestSlotModel(
    slotId: 13,
    productId: 3,
    harvestStartLabel: '10.19',
    harvestEndLabel: '10.25',
    confirmedPrice: 41000,
    confirmedReservableKg: 180,
    availableKg: 35,
    customerNotice: '당도 확인 후 순차 발송됩니다.',
    slotStatus: 'OPEN',
  ),
  HarvestSlotModel(
    slotId: 21,
    productId: 4,
    harvestStartLabel: '10.20',
    harvestEndLabel: '10.27',
    confirmedPrice: 32000,
    confirmedReservableKg: 90,
    availableKg: 42,
    customerNotice: '수확 후 선별을 거쳐 발송됩니다.',
    slotStatus: 'OPEN',
  ),
  HarvestSlotModel(
    slotId: 31,
    productId: 5,
    harvestStartLabel: '09.28',
    harvestEndLabel: '10.04',
    confirmedPrice: 68000,
    confirmedReservableKg: 120,
    availableKg: 75,
    customerNotice: '예약 순서대로 발송 일정이 안내됩니다.',
    slotStatus: 'OPEN',
  ),
  HarvestSlotModel(
    slotId: 41,
    productId: 6,
    harvestStartLabel: '10.05',
    harvestEndLabel: '10.11',
    confirmedPrice: 56000,
    confirmedReservableKg: 80,
    availableKg: 20,
    customerNotice: '잔여 수량이 적어 조기 마감될 수 있습니다.',
    slotStatus: 'OPEN',
  ),
];
