import 'package:flutter/foundation.dart';

import '../../data/models/local_basket_item_model.dart';
import '../../data/repositories/local_basket_repository.dart';

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

  final String defaultReceiverName = '홍길동';
  final String defaultReceiverPhone = '010-1111-2222';
  final String defaultShippingAddress = '서울시 강남구 테헤란로 123';

  String receiverName = '홍길동';
  String receiverPhone = '010-1111-2222';
  String shippingAddress = '서울시 강남구 테헤란로 123';
  String deliveryMemo = '문 앞에 놓아주세요';

  bool get isLoading => _isLoading;
  List<LocalBasketItemModel> get items => _items;

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
    receiverName = value;
    notifyListeners();
  }

  void updateReceiverPhone(String value) {
    receiverPhone = value;
    notifyListeners();
  }

  void updateShippingAddress(String value) {
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
      receiverName = defaultReceiverName;
      receiverPhone = defaultReceiverPhone;
      shippingAddress = defaultShippingAddress;
    }
    notifyListeners();
  }
}
