import 'package:flutter/material.dart';

import '../model/product_model.dart';

class ProductViewModel extends ChangeNotifier {
  final List<ProductModel> products = [
    ProductModel(
      id: '1',
      name: '후지 사과 5kg',
      imageUrl: 'assets/images/apple1.jpg',
      harvestDate: '10.12~10.18',
      description: '충주 햇살농원 · 사과 · 후지 품종',
      price: 39000,
      stockKg: 185,
      reservable: true,
    ),
    ProductModel(
      id: '2',
      name: '홍로 사과 3kg',
      imageUrl: 'assets/images/apple2.jpg',
      harvestDate: '10.20~10.27',
      description: '가정용으로 부담 없이 즐기기 좋은 소포장 사과',
      price: 32000,
      stockKg: 42,
      reservable: true,
    ),
    ProductModel(
      id: '3',
      name: '시나노골드 사과 7.5kg',
      imageUrl: 'assets/images/apple3.jpg',
      harvestDate: '09.28~10.04',
      description: '향이 풍부하고 산미가 산뜻한 예약 한정 사과',
      price: 68000,
      stockKg: 75,
      reservable: true,
    ),
  ];

  ProductModel findById(String? id) {
    return products.firstWhere(
      (product) => product.id == id,
      orElse: () => products.first,
    );
  }
}
