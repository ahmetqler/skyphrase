import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart' show AppThemeVariant;

enum AppLanguage { tr, en }

/// Uygulama dili, renk teması ve ses tercihini tutar, cihazda kalıcı
/// olarak saklar. Diğer her şey (statik metin/renk sınıfları, SoundService)
/// bu provider değiştiğinde güncellenir — bkz. SkyphraseApp'teki tam
/// yeniden kurulum.
class SettingsProvider extends ChangeNotifier {
  static const _kLanguage = 'language';
  static const _kTheme = 'themeVariant';
  static const _kSound = 'soundEnabled';

  AppLanguage _language = AppLanguage.tr;
  AppThemeVariant _themeVariant = AppThemeVariant.blue;
  bool _soundEnabled = true;
  bool _loaded = false;

  AppLanguage get language => _language;
  AppThemeVariant get themeVariant => _themeVariant;
  bool get soundEnabled => _soundEnabled;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final langIndex = prefs.getInt(_kLanguage);
    final themeIndex = prefs.getInt(_kTheme);
    _language = (langIndex != null && langIndex < AppLanguage.values.length)
        ? AppLanguage.values[langIndex]
        : AppLanguage.tr;
    _themeVariant =
        (themeIndex != null && themeIndex < AppThemeVariant.values.length)
            ? AppThemeVariant.values[themeIndex]
            : AppThemeVariant.blue;
    _soundEnabled = prefs.getBool(_kSound) ?? true;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (language == _language) return;
    _language = language;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kLanguage, language.index);
  }

  Future<void> setThemeVariant(AppThemeVariant variant) async {
    if (variant == _themeVariant) return;
    _themeVariant = variant;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTheme, variant.index);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    if (enabled == _soundEnabled) return;
    _soundEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSound, enabled);
  }
}
