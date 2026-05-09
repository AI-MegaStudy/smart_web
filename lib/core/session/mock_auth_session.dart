// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

class MockAuthSession {
  MockAuthSession._();

  static const _accessTokenKey = 'harvest_slot_access_token';
  static const _roleKey = 'harvest_slot_role';

  static bool isLoggedIn = false;
  static String? accessToken;
  static String? role;

  static Future<void> restore() async {
    final token = html.window.localStorage[_accessTokenKey];
    final userRole = html.window.localStorage[_roleKey];
    if (token == null || token.isEmpty) {
      logout();
      return;
    }

    isLoggedIn = true;
    accessToken = token;
    role = userRole;
  }

  static void login({String? token, String? userRole}) {
    isLoggedIn = true;
    accessToken = token;
    role = userRole;
    if (token != null && token.isNotEmpty) {
      html.window.localStorage[_accessTokenKey] = token;
    }
    if (userRole != null && userRole.isNotEmpty) {
      html.window.localStorage[_roleKey] = userRole;
    }
  }

  static void logout() {
    isLoggedIn = false;
    accessToken = null;
    role = null;
    html.window.localStorage.remove(_accessTokenKey);
    html.window.localStorage.remove(_roleKey);
  }
}
