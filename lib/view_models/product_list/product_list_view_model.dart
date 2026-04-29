import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../views/widgets/common/fruit_tile.dart';
import 'product_card_view_data.dart';

class ProductListViewModel {
  const ProductListViewModel({
    required this.products,
  });

  final List<ProductCardViewData> products;

  factory ProductListViewModel.sample() {
    return const ProductListViewModel(
      products: [
        ProductCardViewData(
          name: '장수 후지 사과 5kg',
          subtitle: '농원 프리미엄 · 전북 장수',
          reserveStatus: '예약 가능',
          reserveColor: Color(0xFFE7F5E8),
          reserveTextColor: AppColors.primary,
          price: 39000,
          unitKg: 5.0,
          harvestWindow: '2026.10.12 ~ 10.18',
          availableLabel: '25kg 남음',
          illustration: FruitIllustration.apple,
        ),
        ProductCardViewData(
          name: '홍로 사과 5kg',
          subtitle: '산지 직배송 · 장수 고랭지',
          reserveStatus: '마감 임박',
          reserveColor: Color(0xFFFFF0DD),
          reserveTextColor: Color(0xFFE09024),
          price: 42000,
          unitKg: 5.0,
          harvestWindow: '2026.10.05 ~ 10.10',
          availableLabel: '4kg 남음',
          illustration: FruitIllustration.appleDuo,
        ),
        ProductCardViewData(
          name: '나주 신고 배 7.5kg',
          subtitle: '명절 선물용 · 전남 나주',
          reserveStatus: '예약 가능',
          reserveColor: Color(0xFFE7F5E8),
          reserveTextColor: AppColors.primary,
          price: 52000,
          unitKg: 7.5,
          harvestWindow: '2026.09.20 ~ 09.28',
          availableLabel: '40kg 남음',
          illustration: FruitIllustration.pear,
        ),
        ProductCardViewData(
          name: '천안 배 5kg',
          subtitle: '산지 직배송 · 충남 천안',
          reserveStatus: '예약 가능',
          reserveColor: Color(0xFFE7F5E8),
          reserveTextColor: AppColors.primary,
          price: 45000,
          unitKg: 5.0,
          harvestWindow: '2026.11.02 ~ 11.12',
          availableLabel: '120kg 남음',
          illustration: FruitIllustration.pearCluster,
        ),
      ],
    );
  }
}
