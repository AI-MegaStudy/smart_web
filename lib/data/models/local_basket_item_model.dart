class LocalBasketItemModel {
  const LocalBasketItemModel({
    required this.slotId,
    required this.productId,
    required this.productName,
    required this.farmName,
    required this.harvestStartLabel,
    required this.harvestEndLabel,
    required this.packageUnitKg,
    required this.unitPrice,
    required this.packageCount,
  });

  final int slotId;
  final int productId;
  final String productName;
  final String farmName;
  final String harvestStartLabel;
  final String harvestEndLabel;
  final double packageUnitKg;
  final int unitPrice;
  final int packageCount;

  double get reservedKg => packageUnitKg * packageCount;
  int get subtotalAmount => unitPrice * packageCount;
}
