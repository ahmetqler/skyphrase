import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  /// Şu an aktif AppColors durumuna göre bir ThemeData üretir. AppColors
  /// artık tema değiştirilebilir olduğu için burada const kullanılmıyor.
  static ThemeData get current {
    final brightness = AppColors.isDark ? Brightness.dark : Brightness.light;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        error: AppColors.wrong,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      // Şeffaf: gerçek arka plan rengi + uçan uçak katmanı artık
      // MaterialApp.builder içinde tek bir yerden çiziliyor (bkz. app.dart),
      // her ekran onun üzerinde şeffaf olarak duruyor.
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.textPrimary,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      dialogTheme: DialogThemeData(backgroundColor: AppColors.surface),
    );
  }
}
