import '../models/local_basket_item_model.dart';

class LocalBasketRepository {
  Future<List<LocalBasketItemModel>> fetchItems() async {
    return const [
      LocalBasketItemModel(
        slotId: 12,
        productId: 3,
        productName: '후지 사과 5kg',
        farmName: '청송 햇살농원',
        harvestStartLabel: '10.12',
        harvestEndLabel: '10.18',
        packageUnitKg: 5,
        unitPrice: 39000,
        packageCount: 2,
      ),
      LocalBasketItemModel(
        slotId: 21,
        productId: 4,
        productName: '홍로 사과 3kg',
        farmName: '문경 바람농장',
        harvestStartLabel: '10.20',
        harvestEndLabel: '10.27',
        packageUnitKg: 3,
        unitPrice: 32000,
        packageCount: 1,
      ),
    ];
  }
}
