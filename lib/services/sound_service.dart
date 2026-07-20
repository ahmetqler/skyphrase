import 'package:audioplayers/audioplayers.dart';

/// Uygulama genelindeki geri bildirim seslerini çalar: doğru cevap,
/// yanlış cevap ve genel tıklama sesi. Her ses için ayrı bir AudioPlayer
/// tutulur ki art arda hızlı tıklamalarda sesler birbirini kesmesin/
/// gecikmesin.
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  final _click = AudioPlayer(playerId: 'click');
  final _correct = AudioPlayer(playerId: 'correct');
  final _wrong = AudioPlayer(playerId: 'wrong');

  bool _enabled = true;
  bool get enabled => _enabled;
  set enabled(bool value) => _enabled = value;

  Future<void> _play(AudioPlayer player, String asset) async {
    if (!_enabled) return;
    try {
      await player.stop();
      await player.play(AssetSource(asset), volume: 0.6);
    } catch (_) {
      // Ses çalınamazsa (tarayıcı otomatik oynatma kısıtlaması vb.)
      // sessizce yut — bu asla uygulamayı bozmamalı.
    }
  }

  Future<void> playClick() => _play(_click, 'sounds/click.wav');
  Future<void> playCorrect() => _play(_correct, 'sounds/correct.wav');
  Future<void> playWrong() => _play(_wrong, 'sounds/wrong.wav');
}
