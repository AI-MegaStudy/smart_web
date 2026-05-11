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
    this.productDescription = '',
    this.farmRegion = '',
    this.farmAddress = '',
    this.farmImageUrl = '',
    this.farmDescription = '',
    this.deliveryPolicy = '',
    this.returnPolicy = '',
    this.openSlotCount = 0,
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
  final String productDescription;
  final String farmRegion;
  final String farmAddress;
  final String farmImageUrl;
  final String farmDescription;
  final String deliveryPolicy;
  final String returnPolicy;
  final int openSlotCount;

  int get availablePackageCount => availableKg ~/ packageUnitKg;
  bool get isReservable => openSlotCount > 0 && availableKg > 0 && price > 0;
  bool get isLowStock => isReservable && availablePackageCount <= 5;
  String get farmLabel =>
      farmRegion.trim().isEmpty ? farmName : '$farmName · $farmRegion';
}
