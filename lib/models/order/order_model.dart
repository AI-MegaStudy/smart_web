class OrderModel {
  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.productName,
    required this.totalAmount,
    required this.status,
  });

  final int id;
  final String orderNumber;
  final String productName;
  final int totalAmount;
  final String status;
}
