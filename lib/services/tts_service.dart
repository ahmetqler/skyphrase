import 'package:flutter_tts/flutter_tts.dart';

/// Dinleme egzersizlerinde İngilizce terim/ifadeyi seslendirir. Cihazın
/// kendi konuşma motorunu kullanır (Web'de tarayıcının Web Speech API'si,
/// iOS/Android'de sistem TTS'i) — internetten ses dosyası indirmeye
/// gerek kalmaz, aynı mekanizma tüm platformlarda çalışır.
class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _configured = false;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    _configured = true;
  }

  /// Verilen İngilizce metni sesli okur. Terim/ifade her zaman İngilizce
  /// öğretildiğinden dil her zaman en-US'dir — uygulamanın arayüz dilinden
  /// bağımsızdır.
  Future<void> speak(String text) async {
    await _ensureConfigured();
    await _tts.stop();
    await _tts.speak(text);
  }
}
