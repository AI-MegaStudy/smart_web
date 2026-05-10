import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/order_repository.dart';

class MyPageViewModel extends ChangeNotifier {
  MyPageViewModel({
    AuthRepository? authRepository,
    OrderRepository? orderRepository,
  }) : _authRepository = authRepository ?? AuthRepository(),
       _orderRepository = orderRepository ?? OrderRepository();

  final AuthRepository _authRepository;
  final OrderRepository _orderRepository;

  CurrentUserProfile? profile;
  List<OrderModel> orders = const [];
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  int get activeOrderCount => orders
      .where((order) => !{
            '배송 완료',
            '환불 완료',
            '주문 취소',
          }.contains(order.orderStatusLabel))
      .length;

  String get activeOrderSummary {
    if (activeOrderCount == 0) {
      return '진행 중인 주문 없음';
    }
    return '$activeOrderCount건 진행 중';
  }

  String get recentOrderStatus {
    if (orders.isEmpty) {
      return '주문 내역 없음';
    }
    return orders.first.orderStatusLabel;
  }

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _authRepository.fetchMe(),
        _orderRepository.fetchOrders(),
      ]);
      profile = results[0] as CurrentUserProfile;
      orders = results[1] as List<OrderModel>;
    } on ApiException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = '회원 정보를 불러오지 못했습니다.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
  }) async {
    final normalizedName = name.trim();
    final normalizedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalizedName.length < 2) {
      errorMessage = '이름은 2자 이상 입력해주세요.';
      notifyListeners();
      return false;
    }
    if (normalizedPhone.length < 10 || normalizedPhone.length > 11) {
      errorMessage = '전화번호는 숫자 10~11자리로 입력해주세요.';
      notifyListeners();
      return false;
    }

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      profile = await _authRepository.updateMe(
        name: normalizedName,
        phone: normalizedPhone,
      );
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = '회원 정보를 저장하지 못했습니다.';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
