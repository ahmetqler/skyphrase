import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course.dart';
import '../models/exercise.dart';

/// Bir tekrar kuyruğu kaydı: hangi dersin hangi egzersizi, ve Leitner
/// kutusu (1: yeni yanlış, 2: bir kez doğru, 3: ustalaşmak üzere).
/// Kutu 3'te bir kez daha doğru cevaplanınca kuyruktan tamamen düşer.
class MistakeEntry {
  final String lessonId;
  final int exerciseIndex;
  final int box;

  const MistakeEntry({
    required this.lessonId,
    required this.exerciseIndex,
    this.box = 1,
  });

  String get _key => '$lessonId::$exerciseIndex';

  String encode() => '$lessonId::$exerciseIndex::$box';

  static MistakeEntry? decode(String raw) {
    final parts = raw.split('::');
    if (parts.length != 3) return null;
    final box = int.tryParse(parts[2]);
    if (box == null) return null;
    return MistakeEntry(
        lessonId: parts[0], exerciseIndex: int.parse(parts[1]), box: box);
  }

  MistakeEntry copyWith({int? box}) => MistakeEntry(
        lessonId: lessonId,
        exerciseIndex: exerciseIndex,
        box: box ?? this.box,
      );
}

/// Bir tekrar kuyruğu kaydı + gerçek egzersiz içeriği (Review ekranında
/// gösterilecek).
class ReviewItem {
  final MistakeEntry entry;
  final Exercise exercise;
  const ReviewItem({required this.entry, required this.exercise});
}

/// Kullanıcının yanlış yaptığı sorulardan oluşan, kendiliğinden biriken
/// bir tekrar kuyruğu tutar (basit Leitner / aralıklı tekrar sistemi).
/// Duolingo kullanıcılarının en sık istediği şeylerden biri budur: sadece
/// zorlandığın sorulara odaklanan bir pratik alanı.
class MistakesProvider extends ChangeNotifier {
  static const _kQueue = 'mistakeQueue';
  static const _masteredBox = 3;

  final Map<String, MistakeEntry> _entries = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;
  int get count => _entries.length;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kQueue) ?? [];
    _entries.clear();
    for (final r in raw) {
      final entry = MistakeEntry.decode(r);
      if (entry != null) _entries[entry._key] = entry;
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _kQueue, _entries.values.map((e) => e.encode()).toList());
  }

  /// Bir ders bitince çağrılır: yanlış yapılan sorular kuyruğa girer,
  /// zaten kuyrukta olup bu kez doğru yapılanlar bir kutu ilerler.
  Future<void> recordLessonResults(
      String lessonId, Map<int, bool> results) async {
    for (final e in results.entries) {
      _apply(lessonId, e.key, e.value);
    }
    await _persist();
    notifyListeners();
  }

  /// Tekrar (Review) oturumu sonrası tek bir sorunun sonucunu işler.
  Future<void> recordReviewResult(MistakeEntry entry, bool isCorrect) async {
    _apply(entry.lessonId, entry.exerciseIndex, isCorrect);
    await _persist();
    notifyListeners();
  }

  void _apply(String lessonId, int exerciseIndex, bool isCorrect) {
    final key = '$lessonId::$exerciseIndex';
    final existing = _entries[key];
    if (!isCorrect) {
      _entries[key] = MistakeEntry(
          lessonId: lessonId, exerciseIndex: exerciseIndex, box: 1);
      return;
    }
    if (existing == null) return; // ilk denemede doğruysa kuyruğa hiç girmez
    if (existing.box >= _masteredBox) {
      _entries.remove(key); // ustalaşıldı, kuyruktan düş
    } else {
      _entries[key] = existing.copyWith(box: existing.box + 1);
    }
  }

  /// Kuyruktaki kayıtları gerçek Exercise içeriğiyle eşleştirir. Kurs
  /// içeriği değiştiyse (index artık geçersizse) o kayıt sessizce atlanır.
  List<ReviewItem> resolve(Course course) {
    final byId = {for (final l in course.allLessons) l.id: l};
    final items = <ReviewItem>[];
    for (final entry in _entries.values) {
      final lesson = byId[entry.lessonId];
      if (lesson == null) continue;
      if (entry.exerciseIndex < 0 ||
          entry.exerciseIndex >= lesson.exercises.length) {
        continue;
      }
      final exercise = lesson.exercises[entry.exerciseIndex];
      if (!exercise.isGraded) continue;
      items.add(ReviewItem(entry: entry, exercise: exercise));
    }
    // Yeni yanlışlar (box 1) önce gelsin.
    items.sort((a, b) => a.entry.box.compareTo(b.entry.box));
    return items;
  }
}
