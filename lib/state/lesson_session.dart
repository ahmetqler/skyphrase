import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../models/exercise.dart';

/// Tek bir ders oturumunu yönetir: hangi egzersizdeyiz, kaç doğru/yanlış,
/// kalan can vs. Ders ekranı bu sınıfı dinler.
class LessonSession extends ChangeNotifier {
  final Lesson lesson;
  LessonSession(this.lesson);

  int _index = 0;
  int _correct = 0;
  int _wrong = 0;

  /// Egzersiz index'i -> doğru mu yanlış mı. Tekrar kuyruğu ve geçme eşiği
  /// bu kayıttan besleniyor.
  final Map<int, bool> _results = {};

  int get index => _index;
  int get total => lesson.exercises.length;
  int get gradedTotal =>
      lesson.exercises.where((e) => e.isGraded).length;
  int get correct => _correct;
  int get wrong => _wrong;
  double get progress => total == 0 ? 0 : _index / total;
  bool get isFinished => _index >= total;
  Map<int, bool> get results => Map.unmodifiable(_results);

  /// Doğru cevap oranı (sadece puanlanan egzersizler üzerinden).
  double get accuracy => gradedTotal == 0 ? 1 : _correct / gradedTotal;

  Exercise get current => lesson.exercises[_index];

  void submitResult({required bool isCorrect}) {
    _results[_index] = isCorrect;
    if (isCorrect) {
      _correct++;
    } else {
      _wrong++;
    }
  }

  void next() {
    if (_index < total) {
      _index++;
      notifyListeners();
    }
  }

  int get earnedXp => 10 + _correct * 2;
}
