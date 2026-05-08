import 'package:flutter/foundation.dart';

class AuthViewModel extends ChangeNotifier {
  String email = 'customer@test.com';
  String password = 'pass1234!';
  String name = '홍길동';
  String phone = '010-1111-2222';
  bool marketingAgreed = false;

  bool get canSignup {
    return signupValidationMessage == null;
  }

  bool get isEmailValid {
    return _isValidEmail(email.trim().toLowerCase());
  }

  bool get isPasswordValid {
    return password.trim().length >= 8;
  }

  bool get isNameValid {
    return name.trim().length >= 2;
  }

  bool get isPhoneValid {
    final normalizedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return normalizedPhone.length >= 10 && normalizedPhone.length <= 11;
  }

  String get emailValidationText {
    if (email.trim().isEmpty) {
      return '이메일을 입력해주세요.';
    }
    return isEmailValid ? '사용 가능한 이메일 형식입니다.' : '이메일 형식을 확인해주세요.';
  }

  String get passwordValidationText {
    if (password.trim().isEmpty) {
      return '비밀번호를 입력해주세요.';
    }
    return isPasswordValid ? '비밀번호 조건을 충족했습니다.' : '비밀번호는 8자 이상 입력해주세요.';
  }

  String get nameValidationText {
    if (name.trim().isEmpty) {
      return '이름을 입력해주세요.';
    }
    return isNameValid ? '이름이 입력되었습니다.' : '이름은 2자 이상 입력해주세요.';
  }

  String get phoneValidationText {
    if (phone.trim().isEmpty) {
      return '전화번호를 입력해주세요.';
    }
    return isPhoneValid ? '전화번호 형식이 확인되었습니다.' : '전화번호는 숫자 10~11자리로 입력해주세요.';
  }

  String? get signupValidationMessage {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedName = name.trim();
    final normalizedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (normalizedEmail.isEmpty ||
        password.trim().isEmpty ||
        normalizedName.isEmpty ||
        normalizedPhone.isEmpty) {
      return '이메일, 비밀번호, 이름, 전화번호를 모두 입력해주세요.';
    }

    if (!_isValidEmail(normalizedEmail)) {
      return '이메일 형식을 확인해주세요.';
    }

    if (password.trim().length < 8) {
      return '비밀번호는 8자 이상 입력해주세요.';
    }

    if (normalizedName.length < 2) {
      return '이름은 2자 이상 입력해주세요.';
    }

    if (normalizedPhone.length < 10 || normalizedPhone.length > 11) {
      return '전화번호는 숫자 10~11자리로 입력해주세요.';
    }

    return null;
  }

  void updateEmail(String value) {
    email = value.trim().toLowerCase();
    notifyListeners();
  }

  void updatePassword(String value) {
    password = value;
    notifyListeners();
  }

  void updateName(String value) {
    name = value.trimLeft();
    notifyListeners();
  }

  void updatePhone(String value) {
    phone = _formatPhone(value);
    notifyListeners();
  }

  void updateMarketingAgreed(bool value) {
    marketingAgreed = value;
    notifyListeners();
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  String _formatPhone(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length <= 3) {
      return digits;
    }
    if (digits.length <= 7) {
      return '${digits.substring(0, 3)}-${digits.substring(3)}';
    }
    if (digits.length <= 10) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
    }

    final limited = digits.substring(0, 11);
    return '${limited.substring(0, 3)}-${limited.substring(3, 7)}-${limited.substring(7)}';
  }
}

class EmailVerifyViewModel extends ChangeNotifier {
  String email = 'customer@test.com';
  String code = '481027';
  bool resent = false;

  bool get canVerify {
    return code.trim().length == 6;
  }

  List<String> get codeDigits {
    final normalizedCode = code.padRight(6).substring(0, 6);
    return normalizedCode.split('');
  }

  void updateCode(String value) {
    code = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (code.length > 6) {
      code = code.substring(0, 6);
    }
    notifyListeners();
  }

  void resendCode() {
    resent = true;
    notifyListeners();
  }
}

class LoginViewModel extends ChangeNotifier {
  String email = 'customer@test.com';
  String password = 'pass1234!';

  bool get canLogin {
    return email.trim().isNotEmpty && password.trim().isNotEmpty;
  }

  void updateEmail(String value) {
    email = value;
    notifyListeners();
  }

  void updatePassword(String value) {
    password = value;
    notifyListeners();
  }
}
