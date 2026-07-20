import 'package:flutter/material.dart';

/// Öğretici kartlarda gösterilen terim + tanım çiftinin görsel karşılığı
/// (renkli ikon). Harfler için PhoneticAlphabet kullanılıyor; bu harita
/// diğer tüm terimleri (kelime, sayı, kısaltma) kapsar. Eşleşme yoksa
/// jenerik bir ikon + renk döngüsüyle otomatik düşer, yani yeni bir terim
/// eklenip burası unutulsa bile görsel kırılmaz.
class TermVisual {
  final IconData icon;
  final Color color;
  const TermVisual({required this.icon, required this.color});
}

const _palette = [
  Color(0xFF4C9AFF), // mavi
  Color(0xFFFFC24B), // amber
  Color(0xFF35C46A), // yeşil
  Color(0xFFB983FF), // mor
  Color(0xFFFF7A59), // mercan
  Color(0xFF4BD1E0), // camgöbeği
  Color(0xFFFF5A9E), // pembe
  Color(0xFF8FA6FF), // laciverte çalan mavi
];

final Map<String, IconData> _icons = {
  // Sayılar (havacılık telaffuzu)
  '3': Icons.filter_3,
  '4': Icons.filter_4,
  '5': Icons.filter_5,
  '9': Icons.filter_9,

  // Pilot — telsiz kelimeleri
  'wilco': Icons.task_alt,
  'affirm': Icons.thumb_up,
  'negative': Icons.thumb_down,
  'standby': Icons.hourglass_bottom,
  'say again': Icons.replay,
  'disregard': Icons.block,
  'correction': Icons.autorenew,

  // Teknik — yapı
  'fuselage': Icons.flight,
  'wing': Icons.flight_takeoff,
  'empennage': Icons.change_history,
  'cockpit': Icons.dashboard,
  'landing gear': Icons.tire_repair,

  // Teknik — kontrol yüzeyleri
  'aileron': Icons.rotate_90_degrees_ccw,
  'elevator': Icons.swap_vert,
  'rudder': Icons.compare_arrows,
  'flap': Icons.unfold_more,

  // Teknik — sistemler
  'hydraulic system': Icons.water_drop,
  'avionics': Icons.developer_board,
  'powerplant': Icons.local_fire_department,
  'fuel system': Icons.local_gas_station,

  // Teknik — kısaltmalar
  'mel': Icons.checklist,
  'ad': Icons.gavel,
  'sb': Icons.campaign,
  'ndt': Icons.biotech,

  // Genel — havalimanı
  'boarding pass': Icons.confirmation_number,
  'gate': Icons.meeting_room,
  'check-in': Icons.luggage,
  'departure': Icons.flight_takeoff,
  'arrival': Icons.flight_land,

  // Genel — kabin
  'cabin crew': Icons.support_agent,
  'seatbelt': Icons.lock,
  'overhead bin': Icons.inventory_2,
  'turbulence': Icons.waves,
  'aisle seat': Icons.event_seat,
};

class TermVisuals {
  TermVisuals._();

  static TermVisual forTerm(String term, int fallbackIndex) {
    final icon = _icons[term.trim().toLowerCase()] ?? Icons.menu_book;
    return TermVisual(
      icon: icon,
      color: _palette[fallbackIndex % _palette.length],
    );
  }
}
