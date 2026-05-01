import 'package:flutter/foundation.dart';

import '../../data/models/harvest_slot_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

class ProductDetailViewModel extends ChangeNotifier {
  ProductDetailViewModel({
    required int productId,
    ProductRepository? productRepository,
  }) : _productId = productId,
       _productRepository = productRepository ?? ProductRepository();

  final int _productId;
  final ProductRepository _productRepository;

  bool _isLoading = true;
  ProductModel? _product;
  List<HarvestSlotModel> _slots = const [];
  HarvestSlotModel? _selectedSlot;
  int _packageCount = 1;

  bool get isLoading => _isLoading;
  ProductModel? get product => _product;
  List<HarvestSlotModel> get slots => _slots;
  HarvestSlotModel? get selectedSlot => _selectedSlot;
  int get packageCount => _packageCount;

  double get reservedKg {
    final product = _product;
    if (product == null) {
      return 0;
    }

    return product.packageUnitKg * _packageCount;
  }

  int get subtotalAmount {
    final slot = _selectedSlot;
    if (slot == null) {
      return 0;
    }

    return slot.confirmedPrice * _packageCount;
  }

  int get maxPackageCount {
    final product = _product;
    final slot = _selectedSlot;
    if (product == null || slot == null) {
      return 1;
    }

    final count = slot.availableKg ~/ product.packageUnitKg;
    return count < 1 ? 1 : count;
  }

  bool get canDecrease => _packageCount > 1;
  bool get canIncrease => _packageCount < maxPackageCount;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _product = await _productRepository.fetchProductDetail(_productId);
    _slots = await _productRepository.fetchProductSlots(_productId);
    _selectedSlot = _slots.isEmpty ? null : _slots.first;
    _packageCount = 1;

    _isLoading = false;
    notifyListeners();
  }

  void selectSlot(HarvestSlotModel slot) {
    if (_selectedSlot?.slotId == slot.slotId) {
      return;
    }

    _selectedSlot = slot;
    _packageCount = 1;
    notifyListeners();
  }

  void increasePackageCount() {
    if (!canIncrease) {
      return;
    }

    _packageCount += 1;
    notifyListeners();
  }

  void decreasePackageCount() {
    if (!canDecrease) {
      return;
    }

    _packageCount -= 1;
    notifyListeners();
  }
}
