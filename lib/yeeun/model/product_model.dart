class ProductModel {
  final String id;
  final String name;
  final String imageUrl;
  final String harvestDate;
  final String description;
  final int price;
  final int stockKg;
  final bool reservable;

  ProductModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.harvestDate,
    required this.description,
    required this.price,
    required this.stockKg,
    required this.reservable,
  });
}
