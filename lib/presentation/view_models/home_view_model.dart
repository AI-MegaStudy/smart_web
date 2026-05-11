import 'package:flutter/foundation.dart';

import '../../data/models/product_model.dart';
import '../../data/repositories/product_api_repository.dart';
import '../../data/repositories/repository_contracts.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({ProductRepositoryContract? productRepository})
    : _productRepository = productRepository ?? ProductApiRepository();

  final ProductRepositoryContract _productRepository;

  bool _isLoading = true;
  List<ProductModel> _products = const [];
  List<ProductModel> _featuredProducts = const [];

  bool get isLoading => _isLoading;
  List<ProductModel> get featuredProducts => _featuredProducts;
  ProductModel? get representativeProduct => _mostStockedApple(_products);

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    final products = await _productRepository.fetchFeaturedProducts();
    _products = products;
    _featuredProducts = _currentMonthProducts(products);
    _isLoading = false;
    notifyListeners();
  }

  ProductModel? _mostStockedApple(List<ProductModel> products) {
    final appleProducts =
        products
            .where(
              (product) =>
                  product.isReservable &&
                  (product.name.contains('사과') ||
                      product.variety == '부사' ||
                      product.variety == '양광'),
            )
            .toList()
          ..sort((a, b) => b.availableKg.compareTo(a.availableKg));

    if (appleProducts.isEmpty) {
      return null;
    }

    return appleProducts.first;
  }

  List<ProductModel> _currentMonthProducts(List<ProductModel> products) {
    final now = DateTime.now();
    final filtered =
        products
            .where(
              (product) => _monthOf(product.harvestStartLabel) == now.month,
            )
            .toList()
          ..sort((a, b) {
            final aDay = _dayOf(a.harvestStartLabel);
            final bDay = _dayOf(b.harvestStartLabel);
            return aDay.compareTo(bDay);
          });

    return filtered.take(3).toList(growable: false);
  }

  int? _monthOf(String label) {
    final parts = label.split('.');
    if (parts.length < 2) {
      return null;
    }
    return int.tryParse(parts.first);
  }

  int _dayOf(String label) {
    final parts = label.split('.');
    if (parts.length < 2) {
      return 0;
    }
    return int.tryParse(parts[1]) ?? 0;
  }
}
