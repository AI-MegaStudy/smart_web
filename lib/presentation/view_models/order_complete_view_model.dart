import 'package:flutter/foundation.dart';

import '../../data/models/local_basket_item_model.dart';
import '../../data/repositories/local_basket_repository.dart';

class OrderCompleteViewModel extends ChangeNotifier {
  OrderCompleteViewModel({
    required this.orderId,
    LocalBasketRepository? localBasketRepository,
  }) : _localBasketRepository =
           localBasketRepository ?? LocalBasketRepository();

  final int orderId;
  final LocalBasketRepository _localBasketRepository;

  bool _isLoading = true;
  List<LocalBasketItemModel> _items = const [];

  bool get isLoading => _isLoading;
  List<LocalBasketItemModel> get items => _items;
  String get orderNumber =>
      'ORD-20261012-${orderId.toString().padLeft(3, '0')}';

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
}
