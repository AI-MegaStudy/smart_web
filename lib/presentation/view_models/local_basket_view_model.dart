import 'package:flutter/foundation.dart';

import '../../data/models/local_basket_item_model.dart';
import '../../data/repositories/local_basket_repository.dart';

class LocalBasketViewModel extends ChangeNotifier {
  LocalBasketViewModel({LocalBasketRepository? localBasketRepository})
    : _localBasketRepository = localBasketRepository ?? LocalBasketRepository();

  final LocalBasketRepository _localBasketRepository;

  bool _isLoading = true;
  List<LocalBasketItemModel> _items = const [];
  Set<String> _selectedItemKeys = const {};

  bool get isLoading => _isLoading;
  List<LocalBasketItemModel> get items => _items;
  Set<String> get selectedItemKeys => _selectedItemKeys;
  bool get hasSelectedItems => _selectedItemKeys.isNotEmpty;

  double get totalReservedKg {
    return _items.fold(0, (sum, item) => sum + item.reservedKg);
  }

  int get totalAmount {
    return _items.fold(0, (sum, item) => sum + item.subtotalAmount);
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _items = await _localBasketRepository.fetchItems();
    _selectedItemKeys = {};
    _isLoading = false;
    notifyListeners();
  }

  void removeItem(LocalBasketItemModel item) {
    _localBasketRepository.removeItem(item);
    _items = _items
        .where(
          (basketItem) =>
              basketItem.productId != item.productId ||
              basketItem.slotId != item.slotId,
        )
        .toList();
    _selectedItemKeys = _selectedItemKeys.difference({_itemKey(item)});
    notifyListeners();
  }

  void toggleItemSelection(LocalBasketItemModel item, bool selected) {
    final key = _itemKey(item);
    if (selected) {
      _selectedItemKeys = {..._selectedItemKeys, key};
    } else {
      _selectedItemKeys = _selectedItemKeys
          .where((itemKey) => itemKey != key)
          .toSet();
    }
    notifyListeners();
  }

  void removeSelectedItems() {
    if (_selectedItemKeys.isEmpty) {
      return;
    }

    _items = _items
        .where((item) => !_selectedItemKeys.contains(_itemKey(item)))
        .toList();
    _localBasketRepository.replaceItems(_items);
    _selectedItemKeys = {};
    notifyListeners();
  }

  void increasePackageCount(LocalBasketItemModel item) {
    _updatePackageCount(item, item.packageCount + 1);
  }

  void decreasePackageCount(LocalBasketItemModel item) {
    if (item.packageCount <= 1) {
      return;
    }

    _updatePackageCount(item, item.packageCount - 1);
  }

  bool isSelected(LocalBasketItemModel item) {
    return _selectedItemKeys.contains(_itemKey(item));
  }

  void _updatePackageCount(LocalBasketItemModel target, int packageCount) {
    _items = [
      for (final item in _items)
        if (_itemKey(item) == _itemKey(target))
          LocalBasketItemModel(
            slotId: item.slotId,
            productId: item.productId,
            productName: item.productName,
            farmName: item.farmName,
            harvestStartLabel: item.harvestStartLabel,
            harvestEndLabel: item.harvestEndLabel,
            packageUnitKg: item.packageUnitKg,
            unitPrice: item.unitPrice,
            packageCount: packageCount,
          )
        else
          item,
    ];
    _localBasketRepository.replaceItems(_items);
    notifyListeners();
  }

  String _itemKey(LocalBasketItemModel item) {
    return '${item.productId}-${item.slotId}';
  }
}
