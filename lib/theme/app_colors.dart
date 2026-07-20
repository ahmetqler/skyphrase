import 'package:flutter/material.dart';

enum AppThemeVariant { blue, black, light, pink }

/// Bir renk temasının tüm alanları. Her AppThemeVariant için bir örnek
/// vardır (bkz. _themes). Değerler const olduğu için tema tanımları
/// derleme zamanında sabittir; sadece HANGİ temanın aktif olduğu
/// (AppColors._active) çalışma zamanında değişir.
class AppThemePalette {
  final bool isDark;
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color primary;
  final Color primaryDark;
  final Color primarySoft;
  final Color accent;
  final Color correct;
  final Color correctBg;
  final Color wrong;
  final Color wrongBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color locked;

  const AppThemePalette({
    required this.isDark,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.primary,
    required this.primaryDark,
    required this.primarySoft,
    required this.accent,
    required this.correct,
    required this.correctBg,
    required this.wrong,
    required this.wrongBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.locked,
  });
}

const _blue = AppThemePalette(
  isDark: true,
  background: Color(0xFF0E1626), // yumuşak derin lacivert
  surface: Color(0xFF17223A),
  surfaceAlt: Color(0xFF1E2B47),
  border: Color(0xFF2A3757),
  primary: Color(0xFF4C9AFF),
  primaryDark: Color(0xFF2F6FD0),
  primarySoft: Color(0xFF1C3050),
  accent: Color(0xFFFFC24B),
  correct: Color(0xFF35C46A),
  correctBg: Color(0xFF14311F),
  wrong: Color(0xFFFF5A5A),
  wrongBg: Color(0xFF33191E),
  textPrimary: Color(0xFFEAF0FA),
  textSecondary: Color(0xFF93A2BD),
  locked: Color(0xFF3A4767),
);

const _black = AppThemePalette(
  isDark: true,
  background: Color(0xFF000000),
  surface: Color(0xFF141414),
  surfaceAlt: Color(0xFF1F1F1F),
  border: Color(0xFF2C2C2C),
  primary: Color(0xFF4FA8FF),
  primaryDark: Color(0xFF2F6FD0),
  primarySoft: Color(0xFF16233A),
  accent: Color(0xFFFFC24B),
  correct: Color(0xFF35C46A),
  correctBg: Color(0xFF102818),
  wrong: Color(0xFFFF5A5A),
  wrongBg: Color(0xFF2A1215),
  textPrimary: Color(0xFFF5F5F5),
  textSecondary: Color(0xFF9C9C9C),
  locked: Color(0xFF2E2E2E),
);

const _light = AppThemePalette(
  isDark: false,
  background: Color(0xFFFAFBFF),
  surface: Color(0xFFFFFFFF),
  surfaceAlt: Color(0xFFF0F3F9),
  border: Color(0xFFDDE3EE),
  primary: Color(0xFF3478E0),
  primaryDark: Color(0xFF255DB8),
  primarySoft: Color(0xFFE3EDFF),
  // Eski değer (0xFFE79A1D) beyaza yakın arka planda düşük kontrastlıydı
  // (~2.3:1) — koyulaştırılmış ton aynı turuncu tonda kalıp kontrastı
  // ~4:1'e çıkarır.
  accent: Color(0xFFA66D12),
  correct: Color(0xFF1F9C52),
  correctBg: Color(0xFFE3F7EA),
  wrong: Color(0xFFE03A3A),
  wrongBg: Color(0xFFFBE4E4),
  textPrimary: Color(0xFF1B2333),
  textSecondary: Color(0xFF5C6B85),
  locked: Color(0xFFC7CEDC),
);

const _pink = AppThemePalette(
  isDark: false,
  background: Color(0xFFF6C9DD),
  surface: Color(0xFFFFFFFF),
  surfaceAlt: Color(0xFFFFE3EF),
  border: Color(0xFFFAC7DD),
  primary: Color(0xFFFF5FA2),
  primaryDark: Color(0xFFE0448A),
  primarySoft: Color(0xFFFFDCEB),
  // Eski değer (0xFFB983FF) pembe arka plana karşı çok düşük kontrastlıydı
  // (~1.85:1 — bu yüzden örn. seri/streak ikonu neredeyse kayboluyordu).
  // Aynı mor tonda kalıp koyulaştırılmış hali kontrastı ~3.5:1'e çıkarır.
  accent: Color(0xFF8D37FF),
  correct: Color(0xFF33B679),
  correctBg: Color(0xFFE3F8EE),
  wrong: Color(0xFFFF5C7A),
  wrongBg: Color(0xFFFFE1E7),
  textPrimary: Color(0xFF4A1533),
  textSecondary: Color(0xFF9A6480),
  locked: Color(0xFFF3C9DC),
);

/// Şu an seçili renk teması. Alanlar `static Color get` şeklinde, aktif
/// AppThemePalette'e yönlendirir — SettingsProvider tema değiştirdiğinde
/// [AppColors.applyVariant] çağrılır ve uygulama kökten yeniden kurulur
/// (bkz. app.dart), böylece her widget güncel rengi okur.
class AppColors {
  AppColors._();

  static AppThemeVariant _variant = AppThemeVariant.blue;
  static AppThemePalette _active = _blue;

  static AppThemeVariant get variant => _variant;

  static void applyVariant(AppThemeVariant variant) {
    _variant = variant;
    _active = switch (variant) {
      AppThemeVariant.blue => _blue,
      AppThemeVariant.black => _black,
      AppThemeVariant.light => _light,
      AppThemeVariant.pink => _pink,
    };
  }

  static bool get isDark => _active.isDark;
  static Color get background => _active.background;
  static Color get surface => _active.surface;
  static Color get surfaceAlt => _active.surfaceAlt;
  static Color get border => _active.border;
  static Color get primary => _active.primary;
  static Color get primaryDark => _active.primaryDark;
  static Color get primarySoft => _active.primarySoft;
  static Color get accent => _active.accent;
  static Color get correct => _active.correct;
  static Color get correctBg => _active.correctBg;
  static Color get wrong => _active.wrong;
  static Color get wrongBg => _active.wrongBg;
  static Color get textPrimary => _active.textPrimary;
  static Color get textSecondary => _active.textSecondary;
  static Color get locked => _active.locked;

  /// Bir rengi belirtilen oranda koyulaştırır (3D buton kenarı vb. için).
  static Color darken(Color c, [double amount = 0.22]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Bir rengi belirtilen oranda açar (açık temada gölge/kenar için).
  static Color lighten(Color c, [double amount = 0.22]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }
}
