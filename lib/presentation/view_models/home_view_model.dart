import 'package:flutter/foundation.dart';

import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/repository_contracts.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({ProductRepositoryContract? productRepository})
    : _productRepository = productRepository ?? ProductRepository();

  final ProductRepositoryContract _productRepository;

  bool _isLoading = true;
  List<ProductModel> _featuredProducts = const [];

  bool get isLoading => _isLoading;
  List<ProductModel> get featuredProducts => _featuredProducts;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _featuredProducts = await _productRepository.fetchFeaturedProducts();
    _isLoading = false;
    notifyListeners();
  }
}
