import '../../core/api/api_client.dart';
import '../../core/session/mock_auth_session.dart';

class CustomerAddress {
  const CustomerAddress({
    required this.addressId,
    required this.label,
    required this.receiverName,
    required this.receiverPhone,
    required this.zipCode,
    required this.address,
    required this.detailAddress,
    required this.deliveryMemo,
    required this.isDefault,
    required this.isRecent,
  });

  final int addressId;
  final String label;
  final String receiverName;
  final String receiverPhone;
  final String zipCode;
  final String address;
  final String detailAddress;
  final String deliveryMemo;
  final bool isDefault;
  final bool isRecent;

  String get fullAddress {
    if (detailAddress.trim().isEmpty) {
      return address;
    }
    return '$address $detailAddress';
  }
}

class AddressRepository {
  AddressRepository({ApiClient? apiClient})
    : _apiClient =
          apiClient ??
          ApiClient(
            accessTokenProvider: () async => MockAuthSession.accessToken,
          );

  final ApiClient _apiClient;

  Future<List<CustomerAddress>> fetchAddresses() {
    return _apiClient.getData<List<CustomerAddress>>(
      '/me/addresses',
      requiresAuth: true,
      parser: (data) {
        final rows = data as List<dynamic>? ?? const [];
        return rows
            .whereType<Map<String, dynamic>>()
            .map(_addressFromJson)
            .toList(growable: false);
      },
    );
  }

  Future<CustomerAddress> saveAddress({
    int? addressId,
    required String label,
    required String receiverName,
    required String receiverPhone,
    required String zipCode,
    required String address,
    required String detailAddress,
    required String deliveryMemo,
    required bool isDefault,
  }) {
    final body = {
      'address_label': label.trim().isEmpty ? null : label.trim(),
      'receiver_name': receiverName.trim(),
      'receiver_phone': receiverPhone.trim(),
      'zip_code': zipCode.trim().isEmpty ? null : zipCode.trim(),
      'address': address.trim(),
      'detail_address': detailAddress.trim().isEmpty
          ? null
          : detailAddress.trim(),
      'delivery_memo': deliveryMemo.trim().isEmpty ? null : deliveryMemo.trim(),
      'is_default': isDefault,
    };

    if (addressId == null) {
      return _apiClient.postData<CustomerAddress>(
        '/me/addresses',
        requiresAuth: true,
        body: body,
        parser: (data) =>
            _addressFromJson(data as Map<String, dynamic>? ?? const {}),
      );
    }

    return _apiClient.putData<CustomerAddress>(
      '/me/addresses/$addressId',
      requiresAuth: true,
      body: body,
      parser: (data) =>
          _addressFromJson(data as Map<String, dynamic>? ?? const {}),
    );
  }

  static CustomerAddress _addressFromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      addressId: _asInt(json['address_id']),
      label: json['address_label']?.toString() ?? '',
      receiverName: json['receiver_name']?.toString() ?? '',
      receiverPhone: _formatPhone(json['receiver_phone']?.toString() ?? ''),
      zipCode: json['zip_code']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      detailAddress: json['detail_address']?.toString() ?? '',
      deliveryMemo: json['delivery_memo']?.toString() ?? '문 앞에 놓아주세요',
      isDefault: json['is_default'] == true,
      isRecent: json['is_recent'] == true,
    );
  }

  static int _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _formatPhone(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 11) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    }
    return value;
  }
}
