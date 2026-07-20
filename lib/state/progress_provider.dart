import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../data/aviation_track.dart';

/// Kullanıcının ilerlemesini yönetir: XP, günlük seri (streak), haftalık
/// XP, tamamlanan dersler ve seçtiği öğrenme alanı (parkur). Veriler
/// Firestore'da hesaba bağlı olarak saklanır (`users/{uid}`) — böylece
/// aynı hesapla farklı bir cihazdan giriş yapınca ilerleme kaybolmaz.
class ProgressProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  String? _uid;
  int _xp = 0;
  int _streak = 0;
  int? _lastActiveDay;
  final Set<int> _activeDays = {};
  int _weeklyXp = 0;
  Set<String> _completedLessons = {};
  AviationTrack? _track;
  bool _loaded = false;
  bool _onboardingSeen = false;

  int get xp => _xp;
  int get streak => _streak;
  int get weeklyXp => _weeklyXp;
  bool get isLoaded => _loaded;
  Set<String> get completedLessons => _completedLessons;
  AviationTrack? get track => _track;
  bool get onboardingSeen => _onboardingSeen;

  /// Verilen günde pratik yapılmış mı? Seri takviminde her hücreyi
  /// boyamak için kullanılır.
  bool wasActiveOn(DateTime day) => _activeDays.contains(_dayNumber(day));

  /// Tanıtım turu tamamlanınca (ya da atlanınca) çağrılır — hesaba
  /// kaydedilir ki bir daha giriş yapınca tekrar gösterilmesin.
  Future<void> completeOnboarding() async {
    _onboardingSeen = true;
    notifyListeners();
    if (_uid == null) return;
    await _doc.set({'onboardingSeen': true}, SetOptions(merge: true));
  }

  bool isLessonCompleted(String lessonId) =>
      _completedLessons.contains(lessonId);

  Future<void> chooseTrack(AviationTrack track) async {
    _track = track;
    notifyListeners();
    if (_uid == null) return;
    await _doc.set({'track': track.id}, SetOptions(merge: true));
  }

  DocumentReference<Map<String, dynamic>> get _doc =>
      _db.collection('users').doc(_uid);

  /// Bir kullanıcı giriş yapınca çağrılır: o hesabın verisini Firestore'dan
  /// çeker. Aynı uid zaten bağlıysa tekrar çekmez.
  Future<void> bind(String uid) async {
    if (_uid == uid && _loaded) return;
    _uid = uid;
    _loaded = false;
    notifyListeners();

    final snap = await _doc.get();
    final data = snap.data() ?? {};
    _xp = (data['xp'] as num?)?.toInt() ?? 0;
    _streak = (data['streak'] as num?)?.toInt() ?? 0;
    _weeklyXp = (data['weeklyXp'] as num?)?.toInt() ?? 0;
    _completedLessons =
        Set<String>.from((data['completedLessons'] as List?) ?? const []);
    final trackId = data['track'] as String?;
    _track = trackId == null ? null : AviationTrackInfo.fromId(trackId);
    _onboardingSeen = data['onboardingSeen'] as bool? ?? false;
    _lastActiveDay = (data['lastActiveDay'] as num?)?.toInt();
    _activeDays
      ..clear()
      ..addAll(((data['activeDays'] as List?) ?? const [])
          .map((e) => (e as num).toInt()));

    await _updateWeek((data['weekNumber'] as num?)?.toInt());

    _loaded = true;
    notifyListeners();
  }

  /// Çıkış yapılınca (ya da henüz giriş yokken) çağrılır.
  void unbind() {
    _uid = null;
    _xp = 0;
    _streak = 0;
    _lastActiveDay = null;
    _activeDays.clear();
    _weeklyXp = 0;
    _completedLessons = {};
    _track = null;
    _loaded = false;
    _onboardingSeen = false;
    notifyListeners();
  }

  /// Bir ders tamamlandığında çağrılır.
  Future<void> completeLesson(String lessonId, {int earnedXp = 20}) async {
    if (_uid == null) return;
    _completedLessons.add(lessonId);
    await _doc.set({
      'completedLessons': FieldValue.arrayUnion([lessonId]),
    }, SetOptions(merge: true));
    await addXp(earnedXp);
  }

  /// Ders dışı XP kazanımları için (ör. tekrar/pratik oturumu).
  Future<void> addXp(int earnedXp) async {
    if (_uid == null) return;
    _xp += earnedXp;
    _weeklyXp += earnedXp;
    await _doc.set({
      'xp': _xp,
      'weeklyXp': _weeklyXp,
    }, SetOptions(merge: true));
    await _touchStreakForToday();
    notifyListeners();
  }

  /// Serinin tek gerçek kaynağı: yalnızca XP kazandıran bir aktivite
  /// (ders ya da tekrar oturumu tamamlama) olduğunda çağrılır — sadece
  /// uygulamayı açmak seriyi artırmaz, Duolingo'daki gibi gerçekten
  /// pratik yapman gerekir. Bugün zaten aktifsen hiçbir şey değişmez;
  /// dün aktifsen seri +1 artar; bir gün bile atlandıysa 1'e sıfırlanır.
  Future<void> _touchStreakForToday() async {
    final today = _dayNumber(DateTime.now());
    if (_lastActiveDay == today) return;
    _streak = (_lastActiveDay == today - 1) ? _streak + 1 : 1;
    _lastActiveDay = today;
    _activeDays.add(today);
    if (_uid == null) return;
    await _doc.set({
      'streak': _streak,
      'lastActiveDay': today,
      'activeDays': FieldValue.arrayUnion([today]),
    }, SetOptions(merge: true));
  }

  /// Haftalık liderlik tablosu her Pazartesi başlayan haftaya göre sıfırlanır.
  Future<void> _updateWeek(int? lastWeek) async {
    final now = DateTime.now();
    final currentWeek =
        DateTime(now.year, now.month, now.day - (now.weekday - 1))
                .millisecondsSinceEpoch ~/
            Duration.millisecondsPerDay;
    if (lastWeek != null && lastWeek != currentWeek) {
      _weeklyXp = 0;
    }
    if (lastWeek != currentWeek) {
      if (_uid == null) return;
      await _doc.set({
        'weeklyXp': _weeklyXp,
        'weekNumber': currentWeek,
      }, SetOptions(merge: true));
    }
  }

  int _dayNumber(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;
}
