import 'package:flutter/material.dart';

import '../model/product_model.dart';

class ProductViewModel extends ChangeNotifier {
  final List<ProductModel> products = [
    ProductModel(
      id: '1',
      name: '프리미엄 사과 5kg',
      imageUrl: 'assets/images/apple1.jpg',
      harvestDate: '10.12~10.18',
      description: '수확 예정',
      price: 39000,
      stockKg: 110,
      reservable: true,
    ),
    ProductModel(
      id: '2',
      name: '달콤 사과 3kg',
      imageUrl: 'assets/images/apple2.jpg',
      harvestDate: '10.20~10.27',
      description: '수확 예정',
      price: 32000,
      stockKg: 42,
      reservable: true,
    ),
    ProductModel(
      id: '3',
      name: '시나노 골드 사과 7.5kg',
      imageUrl: 'assets/images/apple3.jpg',
      harvestDate: '09.28~10.04',
      description: '수확 예정',
      price: 68000,
      stockKg: 90,
      reservable: true,
    ),
  ];
}
