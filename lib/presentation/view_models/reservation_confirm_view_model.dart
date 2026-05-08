import 'package:flutter/foundation.dart';

import '../../data/models/harvest_slot_model.dart';
import '../../data/models/local_basket_item_model.dart';
import '../../data/repositories/local_basket_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/repository_contracts.dart';

class ReservationConfirmViewModel extends ChangeNotifier {
  ReservationConfirmViewModel({
    LocalBasketRepositoryContract? localBasketRepository,
    ProductRepositoryContract? productRepository,
  }) : _localBasketRepository =
           localBasketRepository ?? LocalBasketRepository(),
       _productRepository = productRepository ?? ProductRepository();

  final LocalBasketRepositoryContract _localBasketRepository;
  final ProductRepositoryContract _productRepository;

  bool _isLoading = true;
  List<LocalBasketItemModel> _items = const [];
  Map<int, String> _itemIssues = const {};

  bool get isLoading => _isLoading;
  List<LocalBasketItemModel> get items => _items;
  bool get hasBlockingIssue => _itemIssues.isNotEmpty;

  double get totalReservedKg {
    return _items.fold(0, (sum, item) => sum + item.reservedKg);
  }

  int get totalAmount {
    return _items.fold(0, (sum, item) => sum + item.subtotalAmount);
  }

  String? issueForItem(LocalBasketItemModel item) {
    return _itemIssues[item.slotId];
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _localBasketRepository.fetchItems();
      _itemIssues = await _validateItems(_items);
    } catch (_) {
      _items = const [];
      _itemIssues = const {};
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<int, String>> _validateItems(
    List<LocalBasketItemModel> items,
  ) async {
    final issues = <int, String>{};

    for (final item in items) {
      final slots = await _productRepository.fetchProductSlots(item.productId);
      final slot = _findSlot(slots, item.slotId);
      if (slot == null) {
        issues[item.slotId] = '선택한 수확 슬롯을 다시 확인해주세요.';
        continue;
      }

      if (slot.slotStatus != 'OPEN') {
        issues[item.slotId] = '현재 예약이 마감된 수확 슬롯입니다.';
        continue;
      }

      final availablePackageCount = slot.availableKg ~/ item.packageUnitKg;
      if (availablePackageCount < item.packageCount) {
        issues[item.slotId] =
            '현재 남은 수량으로는 $availablePackageCount박스까지 예약할 수 있습니다.';
      }
    }

    return issues;
  }

  HarvestSlotModel? _findSlot(List<HarvestSlotModel> slots, int slotId) {
    for (final slot in slots) {
      if (slot.slotId == slotId) {
        return slot;
      }
    }

    return null;
  }
}
