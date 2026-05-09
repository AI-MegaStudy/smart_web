import 'local_basket_item_model.dart';

class OrderModel {
  const OrderModel({
    required this.orderId,
    required this.orderNumber,
    required this.orderStatusLabel,
    required this.receiverName,
    required this.shippingAddress,
    required this.carrierName,
    required this.trackingNumber,
    required this.items,
    this.orderedAt,
    this.paidAt,
  });

  final int orderId;
  final String orderNumber;
  final String orderStatusLabel;
  final String receiverName;
  final String shippingAddress;
  final String carrierName;
  final String trackingNumber;
  final List<LocalBasketItemModel> items;
  final DateTime? orderedAt;
  final DateTime? paidAt;

  int get totalAmount {
    return items.fold(0, (sum, item) => sum + item.subtotalAmount);
  }

  double get totalReservedKg {
    return items.fold(0, (sum, item) => sum + item.reservedKg);
  }
}
