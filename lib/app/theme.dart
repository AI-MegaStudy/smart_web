import 'package:flutter/material.dart';

ThemeData buildHarvestTheme() {
  const primaryGreen = Color(0xFF2F6F4E);
  const warmYellow = Color(0xFFF2B84B);
  const surface = Color(0xFFF7F8F3);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: primaryGreen,
    primary: primaryGreen,
    secondary: warmYellow,
    surface: surface,
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Malgun Gothic',
    fontFamilyFallback: const [
      '맑은 고딕',
      'Noto Sans KR',
      'Pretendard',
      'Apple SD Gothic Neo',
      'Arial Unicode MS',
      'sans-serif',
    ],
    colorScheme: colorScheme,
    scaffoldBackgroundColor: surface,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: surface,
      foregroundColor: Color(0xFF17251C),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0x10000000)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    ),
  );
}
