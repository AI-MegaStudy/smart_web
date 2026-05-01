class ProductModel {
  const ProductModel({
    required this.productId,
    required this.name,
    required this.farmName,
    required this.variety,
    required this.packageUnitKg,
    required this.price,
    required this.harvestStartLabel,
    required this.harvestEndLabel,
    required this.availableKg,
    required this.imageUrl,
  });

  final int productId;
  final String name;
  final String farmName;
  final String variety;
  final double packageUnitKg;
  final int price;
  final String harvestStartLabel;
  final String harvestEndLabel;
  final double availableKg;
  final String imageUrl;

  int get availablePackageCount => availableKg ~/ packageUnitKg;
  bool get isLowStock => availablePackageCount <= 5;
}
