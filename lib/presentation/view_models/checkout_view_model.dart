import 'package:flutter/foundation.dart';

import '../../data/models/local_basket_item_model.dart';
import '../../data/repositories/local_basket_repository.dart';

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
    LocalBasketRepository? localBasketRepository,
  }) : _localBasketRepository =
           localBasketRepository ?? LocalBasketRepository();

  final int reservationId;
  final LocalBasketRepository _localBasketRepository;

  bool _isLoading = true;
  List<LocalBasketItemModel> _items = const [];
  bool useDefaultAddress = true;
  int selectedAddressId = 1;

  final String defaultReceiverName = '홍길동';
  final String defaultReceiverPhone = '010-1111-2222';
  final String defaultShippingAddress = '서울시 강남구 테헤란로 123';

  String receiverName = '홍길동';
  String receiverPhone = '010-1111-2222';
  String shippingAddress = '서울시 강남구 테헤란로 123';
  String deliveryMemo = '문 앞에 놓아주세요';

  final List<CheckoutAddressOption> addressOptions = const [
    CheckoutAddressOption(
      id: 1,
      label: '내집',
      receiverName: '홍길동',
      receiverPhone: '010-1111-2222',
      address: '서울시 강남구 테헤란로 123',
      memo: '문 앞에 놓아주세요',
      isDefault: true,
      isRecent: true,
    ),
    CheckoutAddressOption(
      id: 2,
      label: '부모님댁',
      receiverName: '홍길순',
      receiverPhone: '010-2222-3333',
      address: '경기도 수원시 영통구 광교중앙로 45',
      memo: '배송 전 연락주세요',
    ),
  ];

  bool get isLoading => _isLoading;
  List<LocalBasketItemModel> get items => _items;
  CheckoutAddressOption get selectedAddress {
    return addressOptions.firstWhere(
      (address) => address.id == selectedAddressId,
      orElse: () => addressOptions.first,
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

    _items = await _localBasketRepository.fetchItems();
    _isLoading = false;
    notifyListeners();
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
      selectAddress(1);
      return;
    }
    notifyListeners();
  }

  void selectAddress(int addressId) {
    final address = addressOptions.firstWhere(
      (option) => option.id == addressId,
      orElse: () => addressOptions.first,
    );

    selectedAddressId = address.id;
    useDefaultAddress = address.isDefault;
    receiverName = address.receiverName;
    receiverPhone = address.receiverPhone;
    shippingAddress = address.address;
    deliveryMemo = address.memo;
    notifyListeners();
  }
}
