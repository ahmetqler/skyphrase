import 'package:flutter/foundation.dart';
import '../data/aviation_track.dart';
import '../data/course_repository.dart';
import '../models/course.dart';
import 'settings_provider.dart' show AppLanguage;

class CourseProvider extends ChangeNotifier {
  final CourseRepository _repository;
  CourseProvider(this._repository);

  Course? _course;
  bool _loading = false;
  Object? _error;
  AppLanguage? _language;
  AviationTrack? _track;

  Course? get course => _course;
  bool get loading => _loading;
  Object? get error => _error;

  Future<void> load(AppLanguage language, AviationTrack track) async {
    _language = language;
    _track = track;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _course = await _repository.loadAviationCourse(language, track);
    } catch (e) {
      _error = e;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Dil ya da parkur değiştiğinde çağrılır; ikisi de aynıysa yeniden
  /// yüklemez.
  Future<void> reload(AppLanguage language, AviationTrack? track) async {
    if (track == null) return;
    if (_language == language && _track == track && _course != null) return;
    await load(language, track);
  }
}
