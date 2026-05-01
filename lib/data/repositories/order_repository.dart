import '../models/order_model.dart';
import 'local_basket_repository.dart';

class OrderRepository {
  OrderRepository({LocalBasketRepository? localBasketRepository})
    : _localBasketRepository = localBasketRepository ?? LocalBasketRepository();

  final LocalBasketRepository _localBasketRepository;

  Future<List<OrderModel>> fetchOrders() async {
    final items = await _localBasketRepository.fetchItems();

    return [
      OrderModel(
        orderId: 8,
        orderNumber: 'ORD-20261012-008',
        orderStatusLabel: '농가 확인 중',
        receiverName: '홍길동',
        shippingAddress: '서울시 강남구 테헤란로 123',
        carrierName: 'CJ대한통운',
        trackingNumber: '5891-1202-4810',
        items: items,
      ),
      OrderModel(
        orderId: 14,
        orderNumber: 'ORD-20260928-014',
        orderStatusLabel: '배송 중',
        receiverName: '홍길동',
        shippingAddress: '서울시 강남구 테헤란로 123',
        carrierName: 'CJ대한통운',
        trackingNumber: '5891-1202-4811',
        items: [items.first],
      ),
      OrderModel(
        orderId: 2,
        orderNumber: 'ORD-20260905-002',
        orderStatusLabel: '배송 완료',
        receiverName: '홍길동',
        shippingAddress: '서울시 강남구 테헤란로 123',
        carrierName: 'CJ대한통운',
        trackingNumber: '5891-1202-4812',
        items: [items.last],
      ),
    ];
  }

  Future<OrderModel> fetchOrderDetail(int orderId) async {
    final items = await _localBasketRepository.fetchItems();

    return OrderModel(
      orderId: orderId,
      orderNumber: 'ORD-20261012-${orderId.toString().padLeft(3, '0')}',
      orderStatusLabel: '배송 중',
      receiverName: '홍길동',
      shippingAddress: '서울시 강남구 테헤란로 123',
      carrierName: 'CJ대한통운',
      trackingNumber: '5891-1202-4810',
      items: items,
    );
  }
}
