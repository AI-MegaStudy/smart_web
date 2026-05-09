import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    String? baseUrl,
    Future<String?> Function()? accessTokenProvider,
  }) : _httpClient = httpClient ?? http.Client(),
       _baseUrl = _normalizeBaseUrl(baseUrl ?? defaultBaseUrl),
       _accessTokenProvider = accessTokenProvider;

  static const defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  final http.Client _httpClient;
  final String _baseUrl;
  final Future<String?> Function()? _accessTokenProvider;

  Future<T> getData<T>(
    String path, {
    Map<String, String>? queryParameters,
    T Function(Object? data)? parser,
    bool requiresAuth = false,
  }) async {
    final response = await _httpClient.get(
      _buildUri(path, queryParameters),
      headers: await _headers(requiresAuth: requiresAuth),
    );
    return _decodeData(response, parser);
  }

  Future<T> postData<T>(
    String path, {
    Object? body,
    T Function(Object? data)? parser,
    bool requiresAuth = false,
  }) async {
    final response = await _httpClient.post(
      _buildUri(path),
      headers: await _headers(requiresAuth: requiresAuth),
      body: body == null ? null : jsonEncode(body),
    );
    return _decodeData(response, parser);
  }

  Future<T> putData<T>(
    String path, {
    Object? body,
    T Function(Object? data)? parser,
    bool requiresAuth = false,
  }) async {
    final response = await _httpClient.put(
      _buildUri(path),
      headers: await _headers(requiresAuth: requiresAuth),
      body: body == null ? null : jsonEncode(body),
    );
    return _decodeData(response, parser);
  }

  Future<T> patchData<T>(
    String path, {
    Object? body,
    T Function(Object? data)? parser,
    bool requiresAuth = false,
  }) async {
    final response = await _httpClient.patch(
      _buildUri(path),
      headers: await _headers(requiresAuth: requiresAuth),
      body: body == null ? null : jsonEncode(body),
    );
    return _decodeData(response, parser);
  }

  Future<T> deleteData<T>(
    String path, {
    T Function(Object? data)? parser,
    bool requiresAuth = false,
  }) async {
    final response = await _httpClient.delete(
      _buildUri(path),
      headers: await _headers(requiresAuth: requiresAuth),
    );
    return _decodeData(response, parser);
  }

  Uri _buildUri(String path, [Map<String, String>? queryParameters]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$_baseUrl$normalizedPath');
    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }
    return uri.replace(queryParameters: queryParameters);
  }

  Future<Map<String, String>> _headers({required bool requiresAuth}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (requiresAuth) {
      final token = await _accessTokenProvider?.call();
      if (token == null || token.isEmpty) {
        throw const ApiException(message: '로그인이 필요합니다.');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  T _decodeData<T>(http.Response response, T Function(Object? data)? parser) {
    final decoded = _decodeJson(response);
    final message = decoded['message']?.toString() ?? '요청 처리에 실패했습니다.';

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        message: _toUserMessage(message),
        statusCode: response.statusCode,
        error: decoded['error'],
      );
    }

    final error = decoded['error'];
    if (error != null) {
      throw ApiException(
        message: _toUserMessage(message),
        statusCode: response.statusCode,
        error: error,
      );
    }

    final data = decoded['data'];
    if (parser != null) {
      return parser(data);
    }
    return data as T;
  }

  Map<String, Object?> _decodeJson(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, Object?>) {
        return decoded;
      }
    } catch (_) {
      throw ApiException(
        message: '서버 응답을 확인할 수 없습니다.',
        statusCode: response.statusCode,
      );
    }

    throw ApiException(
      message: '서버 응답 형식이 올바르지 않습니다.',
      statusCode: response.statusCode,
    );
  }

  String _toUserMessage(String message) {
    return switch (message) {
      'validation failed' => '입력한 정보를 다시 확인해주세요.',
      'invalid email or password' => '이메일 또는 비밀번호를 확인해주세요.',
      'email already exists' => '이미 가입된 이메일입니다.',
      'email verification required' => '이메일 인증을 먼저 완료해주세요.',
      'invalid email format' => '이메일 형식을 확인해주세요.',
      'verification resend cooldown' => '잠시 후 인증 메일을 다시 요청해주세요.',
      'verification request not found' =>
        '인증 요청 내역을 찾을 수 없습니다. 인증 메일을 다시 요청해주세요.',
      'verification code already used' => '이미 사용된 인증 코드입니다.',
      'verification code expired' => '인증 코드가 만료되었습니다. 다시 요청해주세요.',
      'invalid verification code' => '인증 코드가 올바르지 않습니다.',
      'failed to send verification email' => '인증 메일을 보내지 못했습니다.',
      'slot not available' => '현재 예약할 수 없는 수확 슬롯입니다.',
      'requested quantity exceeds available_kg' => '준비된 수량을 초과했습니다.',
      'reservation expired' => '예약 가능 시간이 만료되었습니다.',
      'order not found' => '주문 정보를 찾을 수 없습니다.',
      'only delivered orders can be returned' => '배송 완료된 주문만 반품 신청이 가능합니다.',
      'return request already exists' => '이미 반품 요청이 접수된 주문입니다.',
      'forbidden' => '접근 권한이 없습니다.',
      'internal server error' => '서버 처리 중 문제가 발생했습니다.',
      _ => message.isEmpty ? '요청 처리에 실패했습니다.' : message,
    };
  }

  static String _normalizeBaseUrl(String value) {
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }
}
