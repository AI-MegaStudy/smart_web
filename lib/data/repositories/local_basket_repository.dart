import '../models/local_basket_item_model.dart';
import 'repository_contracts.dart';

class LocalBasketRepository implements LocalBasketRepositoryContract {
  static final List<LocalBasketItemModel> _items = [];

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
