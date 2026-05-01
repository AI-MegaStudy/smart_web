import 'package:flutter/foundation.dart';

class AuthViewModel extends ChangeNotifier {
  String email = 'customer@test.com';
  String password = 'pass1234!';
  String name = '홍길동';
  String phone = '010-1111-2222';
  bool marketingAgreed = false;

  bool get canSignup {
    return email.trim().isNotEmpty &&
        password.trim().isNotEmpty &&
        name.trim().isNotEmpty &&
        phone.trim().isNotEmpty;
  }

  void updateEmail(String value) {
    email = value;
    notifyListeners();
  }

  void updatePassword(String value) {
    password = value;
    notifyListeners();
  }

  void updateName(String value) {
    name = value;
    notifyListeners();
  }

  void updatePhone(String value) {
    phone = value;
    notifyListeners();
  }

  void updateMarketingAgreed(bool value) {
    marketingAgreed = value;
    notifyListeners();
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
