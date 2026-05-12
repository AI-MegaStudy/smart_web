import 'package:flutter/foundation.dart';

import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/repository_contracts.dart';
import '../../data/repositories/shipment_repository.dart';
import '../../demo/customer_coach_tour_manager.dart';
import '../../demo/customer_demo_order_data.dart';

class OrderDetailViewModel extends ChangeNotifier {
  OrderDetailViewModel({
    required int orderId,
    OrderRepositoryContract? orderRepository,
    PaymentRepository? paymentRepository,
    ShipmentRepository? shipmentRepository,
  }) : _orderId = orderId,
       _orderRepository = orderRepository ?? OrderRepository(),
       _paymentRepository = paymentRepository ?? PaymentRepository(),
       _shipmentRepository = shipmentRepository ?? ShipmentRepository();

  final int _orderId;
  final OrderRepositoryContract _orderRepository;
  final PaymentRepository _paymentRepository;
  final ShipmentRepository _shipmentRepository;

  bool _isLoading = true;
  OrderModel? _order;
  List<PaymentHistoryItem> _payments = const [];
  ShipmentInfo? _shipment;
  String? _paymentErrorMessage;

  bool get isLoading => _isLoading;
  OrderModel? get order => _order;
  List<PaymentHistoryItem> get payments => _payments;
  ShipmentInfo? get shipment => _shipment;
  String? get paymentErrorMessage => _paymentErrorMessage;

  List<String> get progressLabels {
    return const ['결제 완료', '농가 확인 중', '농가 승인 완료', '배송 중', '배송 완료'];
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    if (CustomerCoachTourManager.instance.isDemoMode) {
      _paymentErrorMessage = null;
      _order =
          CustomerDemoOrderData.orderById(_orderId) ??
          CustomerDemoOrderData.orders().first;
      _payments = CustomerDemoOrderData.paymentsForOrder(_order!.orderId);
      _shipment = CustomerDemoOrderData.shipmentForOrder(_order!.orderId);
      _isLoading = false;
      notifyListeners();
      return;
    }

    _paymentErrorMessage = null;
    _order = await _orderRepository.fetchOrderDetail(_orderId);
    try {
      _payments = await _paymentRepository.fetchOrderPayments(_orderId);
    } catch (_) {
      _payments = const [];
      _paymentErrorMessage = '결제 정보를 불러오지 못했습니다.';
    }
    try {
      _shipment = await _shipmentRepository.fetchOrderShipment(_orderId);
    } catch (_) {
      _shipment = null;
    }
    _isLoading = false;
    notifyListeners();
  }
}
