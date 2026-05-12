import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import '../../data/models/local_basket_item_model.dart';
import '../../data/repositories/address_repository.dart';
import '../../data/repositories/local_basket_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/repository_contracts.dart';
import '../../data/repositories/reservation_repository.dart';
import '../../demo/customer_coach_tour_manager.dart';
import '../../demo/customer_demo_route_defaults.dart';
import '../../demo/customer_demo_seed_data.dart';

class CheckoutAddressOption {
  const CheckoutAddressOption({
    required this.id,
    required this.label,
    required this.receiverName,
    required this.receiverPhone,
    required this.address,
    required this.memo,
    this.isDefault = false,
    this.isRecent = false,
  });

  final int id;
  final String label;
  final String receiverName;
  final String receiverPhone;
  final String address;
  final String memo;
  final bool isDefault;
  final bool isRecent;
}

class CheckoutViewModel extends ChangeNotifier {
  CheckoutViewModel({
    required this.reservationId,
    LocalBasketRepositoryContract? localBasketRepository,
    OrderRepository? orderRepository,
    AddressRepository? addressRepository,
  }) : _localBasketRepository =
           localBasketRepository ?? LocalBasketRepository(),
       _orderRepository = orderRepository ?? OrderRepository(),
       _addressRepository = addressRepository ?? AddressRepository();

  final int reservationId;
  final LocalBasketRepositoryContract _localBasketRepository;
  final OrderRepository _orderRepository;
  final AddressRepository _addressRepository;

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  List<LocalBasketItemModel> _items = const [];
  bool useDefaultAddress = true;
  int selectedAddressId = 1;

  String receiverName = '';
  String receiverPhone = '';
  String shippingAddress = '';
  String deliveryMemo = '문 앞에 놓아주세요';

  List<CheckoutAddressOption> _addressOptions = const [];

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  List<LocalBasketItemModel> get items => _items;
  List<CheckoutAddressOption> get addressOptions => _addressOptions;
  CheckoutAddressOption get selectedAddress {
    if (_addressOptions.isEmpty) {
      return const CheckoutAddressOption(
        id: 0,
        label: '',
        receiverName: '',
        receiverPhone: '',
        address: '',
        memo: '',
      );
    }
    return _addressOptions.firstWhere(
      (address) => address.id == selectedAddressId,
      orElse: () => _addressOptions.first,
    );
  }

  double get totalReservedKg {
    return _items.fold(0, (sum, item) => sum + item.reservedKg);
  }

  int get totalAmount {
    return _items.fold(0, (sum, item) => sum + item.subtotalAmount);
  }

  bool get canSubmit {
    return receiverName.trim().isNotEmpty &&
        receiverPhone.trim().isNotEmpty &&
        shippingAddress.trim().isNotEmpty;
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    if (CustomerCoachTourManager.instance.isDemoMode) {
      _items = CustomerDemoSeedData.demoBasketItems;
      receiverName = '김민수';
      receiverPhone = '010-1234-5678';
      shippingAddress = '경상북도 문경시 데모길 12';
      deliveryMemo = '문 앞에 놓아주세요';
      _addressOptions = const [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final reservationItems = ReservationCheckoutCache.itemsFor(reservationId);
      _items = reservationItems.isNotEmpty
          ? reservationItems
          : await _localBasketRepository.fetchItems();
    } catch (_) {
      _items = const [];
    }

    try {
      final addresses = await _addressRepository.fetchAddresses();
      _addressOptions = addresses
          .map(_checkoutAddressFromModel)
          .toList(growable: false);
      if (_addressOptions.isNotEmpty) {
        final defaultAddress = _addressOptions.firstWhere(
          (address) => address.isDefault,
          orElse: () => _addressOptions.first,
        );
        _selectAddress(defaultAddress.id, notify: false);
      }
    } catch (_) {
      _addressOptions = const [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<int?> createOrder() async {
    if (CustomerCoachTourManager.instance.isDemoMode) {
      OrderPaymentCache.save(
        CustomerDemoRouteDefaults.paymentOrderId,
        CustomerDemoSeedData.demoBasketItems,
      );
      return CustomerDemoRouteDefaults.paymentOrderId;
    }

    if (!canSubmit || _isSubmitting) {
      _errorMessage = '받는 분, 연락처, 배송지를 모두 입력해주세요.';
      notifyListeners();
      return null;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _orderRepository.createFromReservation(
        reservationId: reservationId,
        receiverName: receiverName.trim(),
        receiverPhone: receiverPhone.trim(),
        shippingAddress: shippingAddress.trim(),
        deliveryMemo: deliveryMemo.trim(),
      );
      OrderPaymentCache.save(result.orderId, _items);
      return result.orderId;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return null;
    } catch (_) {
      _errorMessage = '주문서를 완료하지 못했습니다.';
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void updateReceiverName(String value) {
    useDefaultAddress = false;
    receiverName = value;
    notifyListeners();
  }

  void updateReceiverPhone(String value) {
    useDefaultAddress = false;
    receiverPhone = value;
    notifyListeners();
  }

  void updateShippingAddress(String value) {
    useDefaultAddress = false;
    shippingAddress = value;
    notifyListeners();
  }

  void updateDeliveryMemo(String value) {
    deliveryMemo = value;
    notifyListeners();
  }

  void updateUseDefaultAddress(bool value) {
    useDefaultAddress = value;
    if (value) {
      if (_addressOptions.isNotEmpty) {
        _selectAddress(_addressOptions.first.id);
      }
      return;
    }
    notifyListeners();
  }

  void selectAddress(int addressId) {
    _selectAddress(addressId);
  }

  void _selectAddress(int addressId, {bool notify = true}) {
    if (_addressOptions.isEmpty) {
      return;
    }
    final address = _addressOptions.firstWhere(
      (option) => option.id == addressId,
      orElse: () => _addressOptions.first,
    );

    selectedAddressId = address.id;
    useDefaultAddress = address.isDefault;
    receiverName = address.receiverName;
    receiverPhone = address.receiverPhone;
    shippingAddress = address.address;
    deliveryMemo = address.memo;
    if (notify) {
      notifyListeners();
    }
  }

  CheckoutAddressOption _checkoutAddressFromModel(CustomerAddress address) {
    return CheckoutAddressOption(
      id: address.addressId,
      label: address.label.isEmpty ? '기본 배송지' : address.label,
      receiverName: address.receiverName,
      receiverPhone: address.receiverPhone,
      address: address.fullAddress,
      memo: address.deliveryMemo,
      isDefault: address.isDefault,
      isRecent: address.isRecent,
    );
  }
}
