import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/course.dart';
import '../state/settings_provider.dart' show AppLanguage;
import 'aviation_track.dart';

/// Kurs içeriğini assets/courses/*.json dosyalarından yükler. Dosya adı
/// hem parkura (technical/pilot/general) hem de dile (tr/en) göre seçilir
/// — dördü de aynı ünite/ders id şemasını kullanır, böylece ilerleme
/// (tamamlanan dersler) dil ya da parkur değişince kaybolmaz.
class CourseRepository {
  const CourseRepository();

  Future<Course> loadAviationCourse(
    AppLanguage language,
    AviationTrack track,
  ) async {
    final langSuffix = language == AppLanguage.en ? 'en' : 'tr';
    final file = 'assets/courses/aviation_${track.id}_$langSuffix.json';
    final raw = await rootBundle.loadString(file);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return Course.fromJson(json);
  }
}
