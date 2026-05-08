import 'package:flutter/foundation.dart';

import '../../data/models/harvest_slot_model.dart';
import '../../data/models/local_basket_item_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/local_basket_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/repository_contracts.dart';

class ProductDetailViewModel extends ChangeNotifier {
  ProductDetailViewModel({
    required int productId,
    ProductRepositoryContract? productRepository,
    LocalBasketRepositoryContract? localBasketRepository,
  }) : _productId = productId,
       _productRepository = productRepository ?? ProductRepository(),
       _localBasketRepository =
           localBasketRepository ?? LocalBasketRepository();

  final int _productId;
  final ProductRepositoryContract _productRepository;
  final LocalBasketRepositoryContract _localBasketRepository;

  bool _isLoading = true;
  ProductModel? _product;
  List<HarvestSlotModel> _slots = const [];
  HarvestSlotModel? _selectedSlot;
  int _packageCount = 1;
  double _selectedPackageUnitKg = 5;

  bool get isLoading => _isLoading;
  ProductModel? get product => _product;
  List<HarvestSlotModel> get slots => _slots;
  HarvestSlotModel? get selectedSlot => _selectedSlot;
  int get packageCount => _packageCount;
  double get selectedPackageUnitKg => _selectedPackageUnitKg;

  double get reservedKg {
    final product = _product;
    if (product == null) {
      return 0;
    }

    return _selectedPackageUnitKg * _packageCount;
  }

  int get selectedPackagePrice {
    final slot = _selectedSlot;
    if (slot == null) {
      return 0;
    }

    return packagePriceForSlot(slot);
  }

  int get subtotalAmount {
    return selectedPackagePrice * _packageCount;
  }

  int get maxPackageCount {
    final product = _product;
    final slot = _selectedSlot;
    if (product == null || slot == null) {
      return 1;
    }

    final count = slot.availableKg ~/ _selectedPackageUnitKg;
    return count < 1 ? 1 : count;
  }

  bool get canDecrease => _packageCount > 1;
  bool get canIncrease => _packageCount < maxPackageCount;

  int availablePackageCountForSlot(HarvestSlotModel slot) {
    final count = slot.availableKg ~/ _selectedPackageUnitKg;
    return count < 0 ? 0 : count;
  }

  int packagePriceForSlot(HarvestSlotModel slot) {
    final product = _product;
    if (product == null) {
      return 0;
    }

    final ratio = _selectedPackageUnitKg / product.packageUnitKg;
    return (slot.confirmedPrice * ratio).round();
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _product = await _productRepository.fetchProductDetail(_productId);
    _slots = await _productRepository.fetchProductSlots(_productId);
    _selectedSlot = _slots.isEmpty ? null : _slots.first;
    _selectedPackageUnitKg = _product?.packageUnitKg ?? 5;
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

  void selectPackageCount(int count) {
    final nextCount = count.clamp(1, maxPackageCount).toInt();
    if (nextCount == _packageCount) {
      return;
    }

    _packageCount = nextCount;
    notifyListeners();
  }

  void selectPackageUnit(double packageUnitKg) {
    if (packageUnitKg == _selectedPackageUnitKg) {
      return;
    }

    _selectedPackageUnitKg = packageUnitKg;
    if (_packageCount > maxPackageCount) {
      _packageCount = maxPackageCount;
    }
    notifyListeners();
  }

  bool addSelectedReservationToBasket() {
    final product = _product;
    final slot = _selectedSlot;
    if (product == null || slot == null) {
      return false;
    }

    _localBasketRepository.upsertItem(
      LocalBasketItemModel(
        slotId: slot.slotId,
        productId: product.productId,
        productName: product.name,
        farmName: product.farmName,
        harvestStartLabel: slot.harvestStartLabel,
        harvestEndLabel: slot.harvestEndLabel,
        packageUnitKg: _selectedPackageUnitKg,
        unitPrice: packagePriceForSlot(slot),
        packageCount: _packageCount,
      ),
    );
    return true;
  }
}
