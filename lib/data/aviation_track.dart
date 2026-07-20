import 'package:flutter/material.dart';
import '../l10n/strings.dart';

/// Kullanıcının öğrenmek istediği havacılık terminolojisi alanı. İlk
/// girişte seçilir, ders içeriği (assets/courses/aviation_<track>_<dil>.json)
/// buna göre yüklenir.
enum AviationTrack { technical, pilot, general }

extension AviationTrackInfo on AviationTrack {
  String get id => switch (this) {
        AviationTrack.technical => 'technical',
        AviationTrack.pilot => 'pilot',
        AviationTrack.general => 'general',
      };

  String get title => switch (this) {
        AviationTrack.technical => Strings.trackTechnicalTitle,
        AviationTrack.pilot => Strings.trackPilotTitle,
        AviationTrack.general => Strings.trackGeneralTitle,
      };

  String get description => switch (this) {
        AviationTrack.technical => Strings.trackTechnicalDesc,
        AviationTrack.pilot => Strings.trackPilotDesc,
        AviationTrack.general => Strings.trackGeneralDesc,
      };

  IconData get icon => switch (this) {
        AviationTrack.technical => Icons.build_circle_outlined,
        AviationTrack.pilot => Icons.airplanemode_active,
        AviationTrack.general => Icons.travel_explore,
      };

  static AviationTrack fromId(String id) => AviationTrack.values.firstWhere(
        (t) => t.id == id,
        orElse: () => AviationTrack.pilot,
      );
}
