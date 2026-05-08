import '../models/local_basket_item_model.dart';
import 'repository_contracts.dart';

class LocalBasketRepository implements LocalBasketRepositoryContract {
  static final List<LocalBasketItemModel> _items = [
    const LocalBasketItemModel(
      slotId: 12,
      productId: 3,
      productName: '양광 사과',
      farmName: '충주 햇살농원',
      harvestStartLabel: '10.12',
      harvestEndLabel: '10.18',
      packageUnitKg: 5,
      unitPrice: 39000,
      packageCount: 2,
    ),
    const LocalBasketItemModel(
      slotId: 21,
      productId: 4,
      productName: '부사 사과',
      farmName: '문경 바람농장',
      harvestStartLabel: '10.20',
      harvestEndLabel: '10.27',
      packageUnitKg: 3,
      unitPrice: 32000,
      packageCount: 1,
    ),
  ];

  @override
  Future<List<LocalBasketItemModel>> fetchItems() async {
    return List.unmodifiable(_items);
  }

  @override
  void upsertItem(LocalBasketItemModel item) {
    final index = _items.indexWhere(
      (savedItem) =>
          savedItem.productId == item.productId &&
          savedItem.slotId == item.slotId,
    );

    if (index < 0) {
      _items.add(item);
      return;
    }

    _items[index] = item;
  }

  @override
  void removeItem(LocalBasketItemModel item) {
    _items.removeWhere(
      (savedItem) =>
          savedItem.productId == item.productId &&
          savedItem.slotId == item.slotId,
    );
  }

  @override
  void replaceItems(List<LocalBasketItemModel> items) {
    _items
      ..clear()
      ..addAll(items);
  }
}
