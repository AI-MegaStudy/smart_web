import '../../core/api/api_client.dart';
import '../../core/session/mock_auth_session.dart';

class CurrentUserProfile {
  const CurrentUserProfile({
    required this.accountId,
    required this.email,
    required this.role,
    required this.status,
    required this.emailVerified,
    required this.name,
    required this.phone,
    this.defaultShippingAddress,
  });

  final int accountId;
  final String email;
  final String role;
  final String status;
  final bool emailVerified;
  final String name;
  final String phone;
  final String? defaultShippingAddress;
}

class AuthLoginResult {
  const AuthLoginResult({
    required this.accessToken,
    required this.tokenType,
    required this.role,
  });

  final String accessToken;
  final String tokenType;
  final String role;
}

class AuthSignupResult {
  const AuthSignupResult({
    required this.accountId,
    required this.email,
    required this.emailVerificationRequired,
  });

  final int accountId;
  final String email;
  final bool emailVerificationRequired;
}

class EmailVerificationResult {
  const EmailVerificationResult({
    required this.email,
    required this.purpose,
    this.verified,
    this.expiresInMinutes,
    this.resendAvailableSeconds,
    this.devCode,
  });

  final String email;
  final String purpose;
  final bool? verified;
  final int? expiresInMinutes;
  final int? resendAvailableSeconds;
  final String? devCode;
}

class AuthRepository {
  AuthRepository({ApiClient? apiClient})
    : _apiClient =
          apiClient ??
          ApiClient(
            accessTokenProvider: () async => MockAuthSession.accessToken,
          );

  final ApiClient _apiClient;

  Future<AuthLoginResult> login({
    required String email,
    required String password,
  }) {
    return _apiClient.postData<AuthLoginResult>(
      '/auth/login',
      body: {'email': email, 'password': password},
      parser: (data) {
        final json = data as Map<String, dynamic>? ?? const {};
        return AuthLoginResult(
          accessToken: json['access_token']?.toString() ?? '',
          tokenType: json['token_type']?.toString() ?? 'bearer',
          role: json['role']?.toString() ?? '',
        );
      },
    );
  }

  Future<AuthSignupResult> signupCustomer({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) {
    return _apiClient.postData<AuthSignupResult>(
      '/auth/customers/signup',
      body: {
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
      },
      parser: (data) {
        final json = data as Map<String, dynamic>? ?? const {};
        return AuthSignupResult(
          accountId: _asInt(json['account_id']),
          email: json['email']?.toString() ?? email,
          emailVerificationRequired:
              json['email_verification_required'] == true,
        );
      },
    );
  }

  Future<CurrentUserProfile> fetchMe() {
    return _apiClient.getData<CurrentUserProfile>(
      '/me',
      requiresAuth: true,
      parser: _currentUserFromData,
    );
  }

  Future<CurrentUserProfile> updateMe({
    required String name,
    required String phone,
  }) {
    return _apiClient.putData<CurrentUserProfile>(
      '/me',
      requiresAuth: true,
      body: {
        'name': name.trim(),
        'phone': phone.replaceAll(RegExp(r'[^0-9]'), ''),
      },
      parser: _currentUserFromData,
    );
  }

  Future<EmailVerificationResult> sendEmailVerification({
    required String email,
  }) {
    return _apiClient.postData<EmailVerificationResult>(
      '/auth/email/send',
      body: {'email': email, 'purpose': 'SIGNUP'},
      parser: _emailVerificationFromData,
    );
  }

  Future<EmailVerificationResult> resendEmailVerification({
    required String email,
  }) {
    return _apiClient.postData<EmailVerificationResult>(
      '/auth/email/resend',
      body: {'email': email, 'purpose': 'SIGNUP'},
      parser: _emailVerificationFromData,
    );
  }

  Future<EmailVerificationResult> verifyEmail({
    required String email,
    required String code,
  }) {
    return _apiClient.postData<EmailVerificationResult>(
      '/auth/email/verify',
      body: {'email': email, 'code': code, 'purpose': 'SIGNUP'},
      parser: _emailVerificationFromData,
    );
  }

  Future<EmailVerificationResult> fetchEmailVerificationStatus({
    required String email,
  }) {
    return _apiClient.getData<EmailVerificationResult>(
      '/auth/email/status',
      queryParameters: {'email': email, 'purpose': 'SIGNUP'},
      parser: _emailVerificationFromData,
    );
  }

  int _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatPhone(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 10) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    if (digits.length == 11) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    }
    return value;
  }

  EmailVerificationResult _emailVerificationFromData(Object? data) {
    final json = data as Map<String, dynamic>? ?? const {};
    return EmailVerificationResult(
      email: json['email']?.toString() ?? '',
      purpose: json['purpose']?.toString() ?? 'SIGNUP',
      verified: json['verified'] is bool ? json['verified'] as bool : null,
      expiresInMinutes: _asIntOrNull(json['expires_in_minutes']),
      resendAvailableSeconds: _asIntOrNull(json['resend_available_seconds']),
      devCode: json['dev_code']?.toString(),
    );
  }

  int? _asIntOrNull(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString());
  }

  CurrentUserProfile _currentUserFromData(Object? data) {
    final json = data as Map<String, dynamic>? ?? const {};
    final customerProfile = json['customer_profile'] as Map<String, dynamic>?;
    final ownerProfile = json['owner_profile'] as Map<String, dynamic>?;
    final name =
        customerProfile?['customer_name']?.toString() ??
        ownerProfile?['owner_name']?.toString() ??
        '고객';
    final phone =
        customerProfile?['customer_phone']?.toString() ??
        ownerProfile?['owner_phone']?.toString() ??
        '';

    return CurrentUserProfile(
      accountId: _asInt(json['account_id']),
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      emailVerified: json['email_verified'] == true,
      name: name,
      phone: _formatPhone(phone),
      defaultShippingAddress: customerProfile?['default_shipping_address']
          ?.toString(),
    );
  }
}
