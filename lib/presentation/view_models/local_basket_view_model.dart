import 'package:flutter/foundation.dart';

import '../../data/models/local_basket_item_model.dart';
import '../../data/repositories/local_basket_repository.dart';

class LocalBasketViewModel extends ChangeNotifier {
  LocalBasketViewModel({LocalBasketRepository? localBasketRepository})
    : _localBasketRepository = localBasketRepository ?? LocalBasketRepository();

  final LocalBasketRepository _localBasketRepository;

  bool _isLoading = true;
  List<LocalBasketItemModel> _items = const [];

  bool get isLoading => _isLoading;
  List<LocalBasketItemModel> get items => _items;

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
    _isLoading = false;
    notifyListeners();
  }

  void removeItem(LocalBasketItemModel item) {
    _items = _items
        .where(
          (basketItem) =>
              basketItem.productId != item.productId ||
              basketItem.slotId != item.slotId,
        )
        .toList();
    notifyListeners();
  }
}
