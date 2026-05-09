import 'package:flutter/foundation.dart';

import '../../data/models/product_model.dart';
import '../../data/repositories/product_api_repository.dart';
import '../../data/repositories/repository_contracts.dart';

class ProductListViewModel extends ChangeNotifier {
  ProductListViewModel({ProductRepositoryContract? productRepository})
    : _productRepository = productRepository ?? ProductApiRepository();

  final ProductRepositoryContract _productRepository;

  bool _isLoading = true;
  String? _errorMessage;
  String _selectedVariety = '전체';
  List<ProductModel> _products = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
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

  int get openSlotCount =>
      _products.where((product) => product.isReservable).length;
  int get preparingCount =>
      _products.where((product) => !product.isReservable).length;
  int get lowStockCount =>
      _products.where((product) => product.isLowStock).length;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _productRepository.fetchProducts();
    } catch (_) {
      _products = const [];
      _errorMessage = '상품 정보를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.';
    }

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
