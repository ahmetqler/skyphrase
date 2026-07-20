import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../models/course.dart';
import '../state/progress_provider.dart';

/// Bir başarı rozeti: başlık, açıklama, ikon/renk ve kilidinin ne zaman
/// açıldığını belirten bir koşul. Kilit durumu her zaman ProgressProvider
/// (ve gerektiğinde mevcut Course'un ders listesi) üzerinden canlı
/// hesaplanır — ayrı bir "kazanıldı" kaydı tutmaya gerek yok, ilerleme
/// zaten hesapta saklı.
class BadgeDef {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool Function(ProgressProvider progress, Course? course) isUnlocked;

  const BadgeDef({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isUnlocked,
  });
}

class Badges {
  Badges._();

  static bool _allCompleted(Iterable<Lesson> lessons, ProgressProvider p) =>
      lessons.isNotEmpty && lessons.every((l) => p.isLessonCompleted(l.id));

  /// Uçuş temalı bir ilerleme hikayesi: kalkış, irtifa kazanma, uzun
  /// menzil, ünite ustalığı, tüm parkurun tamamlanması.
  static List<BadgeDef> all() => [
        BadgeDef(
          id: 'first_takeoff',
          title: Strings.badgeFirstTakeoffTitle,
          description: Strings.badgeFirstTakeoffDesc,
          icon: Icons.flight_takeoff,
          color: const Color(0xFF4C9AFF),
          isUnlocked: (p, c) => p.completedLessons.isNotEmpty,
        ),
        BadgeDef(
          id: 'cruising_altitude',
          title: Strings.badgeCruisingAltitudeTitle,
          description: Strings.badgeCruisingAltitudeDesc,
          icon: Icons.airplanemode_active,
          color: const Color(0xFFFFC24B),
          isUnlocked: (p, c) => p.streak >= 3,
        ),
        BadgeDef(
          id: 'long_haul',
          title: Strings.badgeLongHaulTitle,
          description: Strings.badgeLongHaulDesc,
          icon: Icons.public,
          color: const Color(0xFF4BD1E0),
          isUnlocked: (p, c) => p.streak >= 7,
        ),
        BadgeDef(
          id: 'unit_captain',
          title: Strings.badgeUnitCaptainTitle,
          description: Strings.badgeUnitCaptainDesc,
          icon: Icons.workspace_premium,
          color: const Color(0xFFB983FF),
          isUnlocked: (p, c) =>
              c != null && c.units.isNotEmpty && _allCompleted(c.units.first.lessons, p),
        ),
        BadgeDef(
          id: 'captains_wings',
          title: Strings.badgeCaptainsWingsTitle,
          description: Strings.badgeCaptainsWingsDesc,
          icon: Icons.military_tech,
          color: const Color(0xFFF5B942),
          isUnlocked: (p, c) => c != null && _allCompleted(c.allLessons, p),
        ),
      ];
}
