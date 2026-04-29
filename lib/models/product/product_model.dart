class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.unitKg,
    required this.harvestWindow,
    required this.availableLabel,
    required this.statusLabel,
  });

  final int id;
  final String name;
  final String subtitle;
  final int price;
  final double unitKg;
  final String harvestWindow;
  final String availableLabel;
  final String statusLabel;
}
