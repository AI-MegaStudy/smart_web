import 'package:flutter/foundation.dart';

import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({ProductRepository? productRepository})
    : _productRepository = productRepository ?? ProductRepository();

  final ProductRepository _productRepository;

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
