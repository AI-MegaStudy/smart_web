import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import '../../data/repositories/auth_repository.dart';

class MyPageViewModel extends ChangeNotifier {
  MyPageViewModel({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  CurrentUserProfile? profile;
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      profile = await _authRepository.fetchMe();
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
