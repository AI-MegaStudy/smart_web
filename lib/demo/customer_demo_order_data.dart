import '../core/utils/order_status_mapper.dart';
import '../data/models/local_basket_item_model.dart';
import '../data/models/order_model.dart';
import '../data/repositories/payment_repository.dart';
import '../data/repositories/shipment_repository.dart';
import 'customer_demo_route_defaults.dart';

class CustomerDemoOrderData {
  static List<OrderModel> orders() {
    return [
      _buildOrder(
        orderId: CustomerDemoRouteDefaults.paymentOrderId,
        orderNumber: 'ORD-202605330',
        orderStatusCode: OrderStatusMapper.procurementRequested,
        receiverName: '김민수',
        receiverPhone: '010-1234-5678',
        shippingAddress: '경상북도 문경시 데모길 12',
        deliveryMemo: '문 앞에 놓아주세요',
        carrierName: '',
        trackingNumber: '',
        serverTotalAmount: 32000,
        orderedAt: DateTime(2026, 5, 12, 14, 10),
        paidAt: DateTime(2026, 5, 12, 14, 12),
        items: [_item(slotId: 301, packageCount: 1)],
      ),
      _buildOrder(
        orderId: 31,
        orderNumber: 'ORD-202605331',
        orderStatusCode: OrderStatusMapper.procurementApproved,
        receiverName: '이서연',
        receiverPhone: '010-2244-8899',
        shippingAddress: '대구광역시 수성구 들안로 81',
        deliveryMemo: '경비실에 맡겨주세요',
        carrierName: '',
        trackingNumber: '',
        serverTotalAmount: 64000,
        orderedAt: DateTime(2026, 5, 11, 11, 5),
        paidAt: DateTime(2026, 5, 11, 11, 8),
        items: [_item(slotId: 311, packageCount: 2)],
      ),
      _buildOrder(
        orderId: 32,
        orderNumber: 'ORD-202605332',
        orderStatusCode: OrderStatusMapper.qualityChecking,
        receiverName: '박지훈',
        receiverPhone: '010-9988-7766',
        shippingAddress: '부산광역시 해운대구 센텀중앙로 79',
        deliveryMemo: '배송 전 연락주세요',
        carrierName: '',
        trackingNumber: '',
        serverTotalAmount: 48000,
        orderedAt: DateTime(2026, 5, 10, 9, 30),
        paidAt: DateTime(2026, 5, 10, 9, 34),
        items: [_item(slotId: 321, packageCount: 1, packageUnitKg: 7.5, unitPrice: 48000)],
      ),
      _buildOrder(
        orderId: 33,
        orderNumber: 'ORD-202605333',
        orderStatusCode: OrderStatusMapper.shipped,
        receiverName: '최은지',
        receiverPhone: '010-6677-5544',
        shippingAddress: '서울특별시 마포구 월드컵북로 43',
        deliveryMemo: '부재 시 문자 주세요',
        carrierName: 'CJ대한통운',
        trackingNumber: '6501-2345-6789',
        serverTotalAmount: 32000,
        orderedAt: DateTime(2026, 5, 9, 16, 10),
        paidAt: DateTime(2026, 5, 9, 16, 13),
        items: [_item(slotId: 331, packageCount: 1)],
      ),
      _buildOrder(
        orderId: CustomerDemoRouteDefaults.deliveredOrderId,
        orderNumber: 'ORD-202605326',
        orderStatusCode: OrderStatusMapper.delivered,
        receiverName: '김민수',
        receiverPhone: '010-1234-5678',
        shippingAddress: '경상북도 문경시 데모길 12',
        deliveryMemo: '문 앞에 놓아주세요',
        carrierName: 'CJ대한통운',
        trackingNumber: '6501-1234-5678',
        serverTotalAmount: 32000,
        orderedAt: DateTime(2026, 5, 7, 13, 5),
        paidAt: DateTime(2026, 5, 7, 13, 8),
        items: [_item(slotId: 341, packageCount: 1)],
      ),
      _buildOrder(
        orderId: 34,
        orderNumber: 'ORD-202605334',
        orderStatusCode: OrderStatusMapper.returnRequested,
        returnStatusCode: OrderStatusMapper.returnRequestRequested,
        receiverName: '정유진',
        receiverPhone: '010-4521-3344',
        shippingAddress: '인천광역시 연수구 센트럴로 123',
        deliveryMemo: '공동현관 비밀번호 2580',
        carrierName: 'CJ대한통운',
        trackingNumber: '6501-7654-3210',
        serverTotalAmount: 32000,
        orderedAt: DateTime(2026, 5, 5, 15, 20),
        paidAt: DateTime(2026, 5, 5, 15, 22),
        items: [_item(slotId: 351, packageCount: 1)],
      ),
      _buildOrder(
        orderId: 35,
        orderNumber: 'ORD-202605335',
        orderStatusCode: OrderStatusMapper.refunded,
        returnStatusCode: OrderStatusMapper.refunded,
        receiverName: '한소라',
        receiverPhone: '010-8877-1122',
        shippingAddress: '광주광역시 서구 상무대로 401',
        deliveryMemo: '문 앞 수령',
        carrierName: 'CJ대한통운',
        trackingNumber: '6501-8888-1111',
        serverTotalAmount: 32000,
        orderedAt: DateTime(2026, 5, 2, 10, 40),
        paidAt: DateTime(2026, 5, 2, 10, 44),
        items: [_item(slotId: 361, packageCount: 1)],
      ),
    ];
  }

  static OrderModel? orderById(int orderId) {
    for (final order in orders()) {
      if (order.orderId == orderId) {
        return order;
      }
    }
    return null;
  }

  static List<PaymentHistoryItem> paymentsForOrder(int orderId) {
    final order = orderById(orderId);
    if (order == null) {
      return const [];
    }

    if (order.orderStatusCode == OrderStatusMapper.refunded) {
      return [
        PaymentHistoryItem(
          paymentStatusLabel: '환불 완료',
          paymentMethodLabel: '카드 결제',
          requestedAmount: order.totalAmount,
          approvedAmount: order.totalAmount,
          approvedAt: order.paidAt,
        ),
      ];
    }

    return [
      PaymentHistoryItem(
        paymentStatusLabel: '결제 완료',
        paymentMethodLabel: '카드 결제',
        requestedAmount: order.totalAmount,
        approvedAmount: order.totalAmount,
        approvedAt: order.paidAt,
      ),
    ];
  }

  static ShipmentInfo? shipmentForOrder(int orderId) {
    final order = orderById(orderId);
    if (order == null) {
      return null;
    }

    switch (order.orderStatusCode) {
      case OrderStatusMapper.shipped:
        return ShipmentInfo(
          carrierName: order.carrierName,
          trackingNumber: order.trackingNumber,
          shipmentStatusLabel: '배송 중',
          shippedPackageCount: order.items.fold(0, (sum, item) => sum + item.packageCount),
          shippedKg: order.totalReservedKg,
          shippedAt: DateTime(2026, 5, 10, 13, 20),
        );
      case OrderStatusMapper.delivered:
      case OrderStatusMapper.returnRequested:
      case OrderStatusMapper.refunded:
        return ShipmentInfo(
          carrierName: order.carrierName,
          trackingNumber: order.trackingNumber,
          shipmentStatusLabel: '배송 완료',
          shippedPackageCount: order.items.fold(0, (sum, item) => sum + item.packageCount),
          shippedKg: order.totalReservedKg,
          shippedAt: DateTime(2026, 5, 8, 9, 30),
          deliveredAt: DateTime(2026, 5, 9, 15, 10),
        );
      case OrderStatusMapper.readyToShip:
        return ShipmentInfo(
          carrierName: '',
          trackingNumber: '',
          shipmentStatusLabel: '배송 준비',
          shippedPackageCount: order.items.fold(0, (sum, item) => sum + item.packageCount),
          shippedKg: order.totalReservedKg,
        );
      default:
        return null;
    }
  }

  static OrderModel _buildOrder({
    required int orderId,
    required String orderNumber,
    required String orderStatusCode,
    String returnStatusCode = '',
    required String receiverName,
    required String receiverPhone,
    required String shippingAddress,
    required String deliveryMemo,
    required String carrierName,
    required String trackingNumber,
    required int serverTotalAmount,
    required DateTime orderedAt,
    required DateTime paidAt,
    required List<LocalBasketItemModel> items,
  }) {
    return OrderModel(
      orderId: orderId,
      orderNumber: orderNumber,
      orderStatusCode: orderStatusCode,
      orderStatusLabel: OrderStatusMapper.labelOf(orderStatusCode),
      returnStatusCode: returnStatusCode,
      returnStatusLabel: returnStatusCode.isEmpty
          ? ''
          : OrderStatusMapper.returnLabelOf(returnStatusCode),
      receiverName: receiverName,
      receiverPhone: receiverPhone,
      shippingAddress: shippingAddress,
      deliveryMemo: deliveryMemo,
      carrierName: carrierName,
      trackingNumber: trackingNumber,
      items: items,
      serverTotalAmount: serverTotalAmount,
      orderedAt: orderedAt,
      paidAt: paidAt,
    );
  }

  static LocalBasketItemModel _item({
    required int slotId,
    required int packageCount,
    double packageUnitKg = 5,
    int unitPrice = 32000,
  }) {
    return LocalBasketItemModel(
      slotId: slotId,
      productId: CustomerDemoRouteDefaults.featuredProductId,
      productName: '부사 사과 예약',
      farmName: '문경 햇살 농장',
      harvestStartLabel: '05.26',
      harvestEndLabel: '05.28',
      packageUnitKg: packageUnitKg,
      unitPrice: unitPrice,
      packageCount: packageCount,
    );
  }

  const CustomerDemoOrderData._();
}
