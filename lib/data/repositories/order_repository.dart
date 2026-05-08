import '../../core/utils/order_status_mapper.dart';
import '../models/order_model.dart';
import 'local_basket_repository.dart';
import 'repository_contracts.dart';

class OrderRepository implements OrderRepositoryContract {
  OrderRepository({LocalBasketRepositoryContract? localBasketRepository})
    : _localBasketRepository = localBasketRepository ?? LocalBasketRepository();

  final LocalBasketRepositoryContract _localBasketRepository;
  static final Set<int> _returnRequestedOrderIds = {};

  @override
  Future<List<OrderModel>> fetchOrders() async {
    final items = await _localBasketRepository.fetchItems();
    if (items.isEmpty) {
      return const [];
    }

    return [
      OrderModel(
        orderId: 8,
        orderNumber: 'ORD-20261012-008',
        orderStatusLabel: _statusLabelFor(8),
        receiverName: '홍길동',
        shippingAddress: '서울시 강남구 테헤란로 123',
        carrierName: 'CJ대한통운',
        trackingNumber: '5891-1202-4810',
        items: items,
      ),
      OrderModel(
        orderId: 14,
        orderNumber: 'ORD-20260928-014',
        orderStatusLabel: _statusLabelFor(14),
        receiverName: '홍길동',
        shippingAddress: '서울시 강남구 테헤란로 123',
        carrierName: 'CJ대한통운',
        trackingNumber: '5891-1202-4811',
        items: [items.first],
      ),
      OrderModel(
        orderId: 2,
        orderNumber: 'ORD-20260905-002',
        orderStatusLabel: _statusLabelFor(2),
        receiverName: '홍길동',
        shippingAddress: '서울시 강남구 테헤란로 123',
        carrierName: 'CJ대한통운',
        trackingNumber: '5891-1202-4812',
        items: [items.last],
      ),
    ];
  }

  @override
  Future<OrderModel> fetchOrderDetail(int orderId) async {
    final items = await _localBasketRepository.fetchItems();

    return OrderModel(
      orderId: orderId,
      orderNumber: 'ORD-20261012-${orderId.toString().padLeft(3, '0')}',
      orderStatusLabel: _statusLabelFor(orderId),
      receiverName: '홍길동',
      shippingAddress: '서울시 강남구 테헤란로 123',
      carrierName: 'CJ대한통운',
      trackingNumber: '5891-1202-4810',
      items: items,
    );
  }

  @override
  Future<void> requestReturn(int orderId) async {
    _returnRequestedOrderIds.add(orderId);
  }

  static String _statusLabelFor(int orderId) {
    if (_returnRequestedOrderIds.contains(orderId)) {
      return OrderStatusMapper.labelOf(OrderStatusMapper.returnRequested);
    }

    return OrderStatusMapper.labelOf(
      OrderStatusMapper.demoStatusCodeForOrderId(orderId),
    );
  }
}
