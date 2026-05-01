import 'package:flutter/foundation.dart';

import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

class ProductListViewModel extends ChangeNotifier {
  ProductListViewModel({ProductRepository? productRepository})
    : _productRepository = productRepository ?? ProductRepository();

  final ProductRepository _productRepository;

  bool _isLoading = true;
  String _selectedVariety = '전체';
  List<ProductModel> _products = const [];

  bool get isLoading => _isLoading;
  String get selectedVariety => _selectedVariety;
  List<ProductModel> get products => _products;

  List<String> get varieties {
    final values = _products.map((product) => product.variety).toSet().toList()
      ..sort();
    return ['전체', ...values];
  }

  List<ProductModel> get filteredProducts {
    if (_selectedVariety == '전체') {
      return _products;
    }

    return _products
        .where((product) => product.variety == _selectedVariety)
        .toList(growable: false);
  }

  int get openSlotCount => _products.length;
  int get lowStockCount =>
      _products.where((product) => product.isLowStock).length;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _products = await _productRepository.fetchProducts();
    _isLoading = false;
    notifyListeners();
  }

  void selectVariety(String variety) {
    if (_selectedVariety == variety) {
      return;
    }

    _selectedVariety = variety;
    notifyListeners();
  }
}
