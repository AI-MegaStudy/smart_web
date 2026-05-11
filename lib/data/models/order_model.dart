import 'local_basket_item_model.dart';

class OrderModel {
  const OrderModel({
    required this.orderId,
    required this.orderNumber,
    required this.orderStatusCode,
    required this.orderStatusLabel,
    required this.returnStatusCode,
    required this.returnStatusLabel,
    required this.receiverName,
    required this.receiverPhone,
    required this.shippingAddress,
    required this.deliveryMemo,
    required this.carrierName,
    required this.trackingNumber,
    required this.items,
    required this.serverTotalAmount,
    this.orderedAt,
    this.paidAt,
  });

  final int orderId;
  final String orderNumber;
  final String orderStatusCode;
  final String orderStatusLabel;
  final String returnStatusCode;
  final String returnStatusLabel;
  final String receiverName;
  final String receiverPhone;
  final String shippingAddress;
  final String deliveryMemo;
  final String carrierName;
  final String trackingNumber;
  final List<LocalBasketItemModel> items;
  final int serverTotalAmount;
  final DateTime? orderedAt;
  final DateTime? paidAt;

  int get totalAmount {
    if (serverTotalAmount > 0) {
      return serverTotalAmount;
    }
    return items.fold(0, (sum, item) => sum + item.subtotalAmount);
  }

  double get totalReservedKg {
    return items.fold(0, (sum, item) => sum + item.reservedKg);
  }
}
