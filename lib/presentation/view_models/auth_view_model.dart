import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import '../../core/session/mock_auth_session.dart';
import '../../data/repositories/auth_repository.dart';

class SignupVerificationArgs {
  const SignupVerificationArgs({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    this.emailAlreadySent = false,
  });

  final String email;
  final String password;
  final String name;
  final String phone;
  final bool emailAlreadySent;
}

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  String email = '';
  String password = '';
  String name = '';
  String phone = '';
  bool marketingAgreed = false;
  bool isSubmitting = false;
  String? errorMessage;

  bool get canSignup {
    return signupValidationMessage == null && !isSubmitting;
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
    return isNameValid ? '이름을 입력했습니다.' : '이름은 2자 이상 입력해주세요.';
  }

  String get phoneValidationText {
    if (phone.trim().isEmpty) {
      return '전화번호를 입력해주세요.';
    }
    return isPhoneValid ? '전화번호 형식을 확인했습니다.' : '전화번호는 숫자 10~11자리로 입력해주세요.';
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

  SignupVerificationArgs get signupDraft {
    return SignupVerificationArgs(
      email: email.trim().toLowerCase(),
      password: password,
      name: name.trim(),
      phone: phone.replaceAll(RegExp(r'[^0-9]'), ''),
      emailAlreadySent: true,
    );
  }

  Future<bool> requestEmailVerification() async {
    final validationMessage = signupValidationMessage;
    if (validationMessage != null) {
      errorMessage = validationMessage;
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.sendEmailVerification(
        email: email.trim().toLowerCase(),
      );
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = '인증 메일을 보내지 못했습니다.';
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> signup() async {
    final validationMessage = signupValidationMessage;
    if (validationMessage != null) {
      errorMessage = validationMessage;
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.signupCustomer(
        email: email.trim().toLowerCase(),
        password: password,
        name: name.trim(),
        phone: phone.replaceAll(RegExp(r'[^0-9]'), ''),
      );
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = '회원가입 처리 중 문제가 발생했습니다.';
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
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
  EmailVerifyViewModel({String? initialEmail, this.signupDraft}) {
    if (initialEmail != null && initialEmail.trim().isNotEmpty) {
      email = initialEmail.trim().toLowerCase();
    }
  }

  final SignupVerificationArgs? signupDraft;
  String email = '';
  String code = '';
  bool resent = false;
  bool isSending = false;
  bool isVerifying = false;
  bool isVerified = false;
  String? errorMessage;
  String? devCode;

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

  void updateEmail(String value) {
    email = value.trim().toLowerCase();
    notifyListeners();
  }

  Future<void> sendCode({bool resend = false}) async {
    if (email.trim().isEmpty || isSending) {
      return;
    }

    isSending = true;
    errorMessage = null;
    notifyListeners();

    try {
      final repository = AuthRepository();
      final result = resend
          ? await repository.resendEmailVerification(email: email.trim())
          : await repository.sendEmailVerification(email: email.trim());
      resent = resend;
      devCode = result.devCode;
    } on ApiException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = '인증 메일을 보내지 못했습니다.';
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  Future<bool> verify() async {
    if (!canVerify || isVerifying) {
      errorMessage = '6자리 인증 코드를 입력해주세요.';
      notifyListeners();
      return false;
    }

    isVerifying = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthRepository().verifyEmail(
        email: email.trim(),
        code: code.trim(),
      );
      isVerified = result.verified == true;
      if (!isVerified) {
        errorMessage = '이메일 인증을 완료하지 못했습니다.';
      }
      return isVerified;
    } on ApiException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = '이메일 인증 처리 중 문제가 발생했습니다.';
      return false;
    } finally {
      isVerifying = false;
      notifyListeners();
    }
  }

  Future<bool> completeSignupAfterVerification() async {
    final draft = signupDraft;
    if (draft == null) {
      return true;
    }

    try {
      await AuthRepository().signupCustomer(
        email: draft.email,
        password: draft.password,
        name: draft.name,
        phone: draft.phone,
      );
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return false;
    } catch (_) {
      errorMessage = '회원가입 처리 중 문제가 발생했습니다.';
      notifyListeners();
      return false;
    }
  }

  Future<void> resendCode() async {
    await sendCode(resend: true);
  }
}

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  String email = '';
  String password = '';
  bool isSubmitting = false;
  String? errorMessage;

  bool get canLogin {
    return email.trim().isNotEmpty &&
        password.trim().isNotEmpty &&
        !isSubmitting;
  }

  Future<bool> login() async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      errorMessage = '이메일과 비밀번호를 모두 입력해주세요.';
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.login(
        email: email.trim().toLowerCase(),
        password: password,
      );
      MockAuthSession.login(token: result.accessToken, userRole: result.role);
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = '로그인 처리 중 문제가 발생했습니다.';
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
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
