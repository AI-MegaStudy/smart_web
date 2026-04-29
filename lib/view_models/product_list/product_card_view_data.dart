import 'package:flutter/material.dart';

import '../../views/widgets/common/fruit_tile.dart';

class ProductCardViewData {
  const ProductCardViewData({
    required this.name,
    required this.subtitle,
    required this.reserveStatus,
    required this.reserveColor,
    required this.reserveTextColor,
    required this.price,
    required this.unitKg,
    required this.harvestWindow,
    required this.availableLabel,
    required this.illustration,
  });

  final String name;
  final String subtitle;
  final String reserveStatus;
  final Color reserveColor;
  final Color reserveTextColor;
  final int price;
  final double unitKg;
  final String harvestWindow;
  final String availableLabel;
  final FruitIllustration illustration;
}
