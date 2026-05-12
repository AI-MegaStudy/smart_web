import '../data/models/local_basket_item_model.dart';

class CustomerDemoSeedData {
  static const demoBasketItems = [
    LocalBasketItemModel(
      slotId: 301,
      productId: 3,
      productName: '부사 사과 예약',
      farmName: '문경 햇살 농장',
      harvestStartLabel: '05.26',
      harvestEndLabel: '05.28',
      packageUnitKg: 5,
      unitPrice: 32000,
      packageCount: 1,
    ),
  ];

  const CustomerDemoSeedData._();
}
