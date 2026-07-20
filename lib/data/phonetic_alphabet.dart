import 'package:flutter/material.dart';
import '../l10n/strings.dart';

/// Harf kartlarının rengi bilinçli olarak seçili renk temasından bağımsız
/// sabit kalır (Delta her zaman aynı mor üçgen olsun ki görsel çağrışım
/// tema değişince bozulmasın).
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

const _kAlphabetAssetPath = 'assets/images/alphabet';

/// ICAO fonetik alfabesindeki bir harf: kod kelimesi, akılda kalması için
/// elle çizilmiş bir illüstrasyon (SVG), yedek olarak bir ikon/renk ve
/// kod kelimesini içeren kısa, akılda kalıcı bir örnek cümle (kart
/// tıklandığında gösterilir).
class PhoneticLetter {
  final String letter;
  final String code;
  final IconData icon;
  final Color color;
  final String imageAsset;
  final String exampleTr;
  final String exampleEn;

  const PhoneticLetter({
    required this.letter,
    required this.code,
    required this.icon,
    required this.color,
    required this.imageAsset,
    required this.exampleTr,
    required this.exampleEn,
  });

  String get example => Strings.isEnglish ? exampleEn : exampleTr;
}

class PhoneticAlphabet {
  PhoneticAlphabet._();

  static final List<PhoneticLetter> all = [
    PhoneticLetter(
      letter: 'A', code: 'Alfa', icon: Icons.flight_takeoff, color: _palette[0],
      imageAsset: '$_kAlphabetAssetPath/a_alpha.svg',
      exampleTr: 'Alpha, listede her zaman ilk sıradadır.',
      exampleEn: 'Alpha always comes first in line.',
    ),
    PhoneticLetter(
      letter: 'B', code: 'Bravo', icon: Icons.celebration, color: _palette[1],
      imageAsset: '$_kAlphabetAssetPath/b_bravo.svg',
      exampleTr: 'Harika bir inişten sonra herkes "Bravo!" diye bağırır.',
      exampleEn: 'After a great landing, everyone shouts "Bravo!"',
    ),
    PhoneticLetter(
      letter: 'C', code: 'Charlie', icon: Icons.theater_comedy, color: _palette[2],
      imageAsset: '$_kAlphabetAssetPath/c_charlie.svg',
      exampleTr: 'Charlie, herkesi güldüren komik palyaçodur.',
      exampleEn: 'Charlie is the clown who makes everyone laugh.',
    ),
    PhoneticLetter(
      letter: 'D', code: 'Delta', icon: Icons.change_history, color: _palette[3],
      imageAsset: '$_kAlphabetAssetPath/d_delta.svg',
      exampleTr: 'Delta, matematikte üçgeni simgeleyen harftir.',
      exampleEn: 'Delta is the triangle symbol used in math.',
    ),
    PhoneticLetter(
      letter: 'E', code: 'Echo', icon: Icons.graphic_eq, color: _palette[4],
      imageAsset: '$_kAlphabetAssetPath/e_echo.svg',
      exampleTr: 'Dağda bağırınca sesin geri döner, buna echo denir.',
      exampleEn: 'Shout in the mountains and your echo shouts back.',
    ),
    PhoneticLetter(
      letter: 'F', code: 'Foxtrot', icon: Icons.pets, color: _palette[5],
      imageAsset: '$_kAlphabetAssetPath/f_foxtrot.svg',
      exampleTr: 'Foxtrot, bir tilki kadar çevik bir dans adımıdır.',
      exampleEn: 'Foxtrot is a dance step as quick as a fox.',
    ),
    PhoneticLetter(
      letter: 'G', code: 'Golf', icon: Icons.sports_golf, color: _palette[6],
      imageAsset: '$_kAlphabetAssetPath/g_golf.svg',
      exampleTr: 'Golf sahasında topu deliğe sokman gerekir.',
      exampleEn: 'In golf, you sink the ball into the hole.',
    ),
    PhoneticLetter(
      letter: 'H', code: 'Hotel', icon: Icons.hotel, color: _palette[7],
      imageAsset: '$_kAlphabetAssetPath/h_hotel.svg',
      exampleTr: 'Uzun bir yolculuk sonrası dinlenmek için bir hotel\'e gidilir.',
      exampleEn: 'After a long trip, you check into a hotel to rest.',
    ),
    PhoneticLetter(
      letter: 'I', code: 'India', icon: Icons.public, color: _palette[0],
      imageAsset: '$_kAlphabetAssetPath/i_india.svg',
      exampleTr: 'India, Tac Mahal\'in bulunduğu ülkedir.',
      exampleEn: 'India is home to the Taj Mahal.',
    ),
    PhoneticLetter(
      letter: 'J', code: 'Juliett', icon: Icons.favorite, color: _palette[1],
      imageAsset: '$_kAlphabetAssetPath/j_juliett.svg',
      exampleTr: 'Romeo, balkondaki Juliett\'e seslenir.',
      exampleEn: 'Romeo calls up to Juliett on the balcony.',
    ),
    PhoneticLetter(
      letter: 'K', code: 'Kilo', icon: Icons.monitor_weight, color: _palette[2],
      imageAsset: '$_kAlphabetAssetPath/k_kilo.svg',
      exampleTr: 'Bir kilo un, bin gram eder.',
      exampleEn: 'One kilo of flour weighs a thousand grams.',
    ),
    PhoneticLetter(
      letter: 'L', code: 'Lima', icon: Icons.location_on, color: _palette[3],
      imageAsset: '$_kAlphabetAssetPath/l_lima.svg',
      exampleTr: 'Lima, Peru\'nun başkentidir.',
      exampleEn: 'Lima is the capital city of Peru.',
    ),
    PhoneticLetter(
      letter: 'M', code: 'Mike', icon: Icons.mic, color: _palette[4],
      imageAsset: '$_kAlphabetAssetPath/m_mike.svg',
      exampleTr: 'Şarkıcı sahnede mike\'a doğru eğilir.',
      exampleEn: 'The singer leans into the mike on stage.',
    ),
    PhoneticLetter(
      letter: 'N', code: 'November', icon: Icons.calendar_month, color: _palette[5],
      imageAsset: '$_kAlphabetAssetPath/n_november.svg',
      exampleTr: 'November, yılın on birinci ayıdır.',
      exampleEn: 'November is the eleventh month of the year.',
    ),
    PhoneticLetter(
      letter: 'O', code: 'Oscar', icon: Icons.emoji_events, color: _palette[6],
      imageAsset: '$_kAlphabetAssetPath/o_oscar.svg',
      exampleTr: 'En iyi filme altın Oscar heykelciği verilir.',
      exampleEn: 'The best film wins the golden Oscar statue.',
    ),
    PhoneticLetter(
      letter: 'P', code: 'Papa', icon: Icons.face, color: _palette[7],
      imageAsset: '$_kAlphabetAssetPath/p_papa.svg',
      exampleTr: 'Papa, çocuğuna güvenle gülümser.',
      exampleEn: 'Papa smiles warmly at his child.',
    ),
    PhoneticLetter(
      letter: 'Q', code: 'Quebec', icon: Icons.ac_unit, color: _palette[0],
      imageAsset: '$_kAlphabetAssetPath/q_quebec.svg',
      exampleTr: 'Quebec, her kış kar altında kalır.',
      exampleEn: 'Quebec gets buried in snow every winter.',
    ),
    PhoneticLetter(
      letter: 'R', code: 'Romeo', icon: Icons.favorite_border, color: _palette[1],
      imageAsset: '$_kAlphabetAssetPath/r_romeo.svg',
      exampleTr: 'Romeo, aşkı için her şeyi göze alır.',
      exampleEn: 'Romeo risks everything for love.',
    ),
    PhoneticLetter(
      letter: 'S', code: 'Sierra', icon: Icons.terrain, color: _palette[2],
      imageAsset: '$_kAlphabetAssetPath/s_sierra.svg',
      exampleTr: 'Sierra, İspanyolca\'da "dağ sırası" demektir.',
      exampleEn: 'Sierra means "mountain range" in Spanish.',
    ),
    PhoneticLetter(
      letter: 'T', code: 'Tango', icon: Icons.groups, color: _palette[3],
      imageAsset: '$_kAlphabetAssetPath/t_tango.svg',
      exampleTr: 'Tango\'yu dans etmek için iki kişi gerekir.',
      exampleEn: 'It takes two people to dance the tango.',
    ),
    PhoneticLetter(
      letter: 'U', code: 'Uniform', icon: Icons.checkroom, color: _palette[4],
      imageAsset: '$_kAlphabetAssetPath/u_uniform.svg',
      exampleTr: 'Bir asker görevde her zaman uniform giyer.',
      exampleEn: 'A soldier always wears a uniform on duty.',
    ),
    PhoneticLetter(
      letter: 'V', code: 'Victor', icon: Icons.military_tech, color: _palette[5],
      imageAsset: '$_kAlphabetAssetPath/v_victor.svg',
      exampleTr: 'Yarışı kazanan victor olur.',
      exampleEn: 'The winner of the race becomes the victor.',
    ),
    PhoneticLetter(
      letter: 'W', code: 'Whiskey', icon: Icons.local_bar, color: _palette[6],
      imageAsset: '$_kAlphabetAssetPath/w_whiskey.svg',
      exampleTr: 'Whiskey, meşe fıçıda yıllarca dinlendirilir.',
      exampleEn: 'Whiskey ages for years inside an oak barrel.',
    ),
    PhoneticLetter(
      letter: 'X', code: 'X-ray', icon: Icons.health_and_safety, color: _palette[7],
      imageAsset: '$_kAlphabetAssetPath/x_xray.svg',
      exampleTr: 'Kırık bir kemik x-ray filminde görünür.',
      exampleEn: 'A broken bone shows up clearly on an x-ray.',
    ),
    PhoneticLetter(
      letter: 'Y', code: 'Yankee', icon: Icons.flag, color: _palette[0],
      imageAsset: '$_kAlphabetAssetPath/y_yankee.svg',
      exampleTr: 'Yankee, Amerikalılar için kullanılan bir lakaptır.',
      exampleEn: 'Yankee is a well-known nickname for an American.',
    ),
    PhoneticLetter(
      letter: 'Z', code: 'Zulu', icon: Icons.travel_explore, color: _palette[1],
      imageAsset: '$_kAlphabetAssetPath/z_zulu.svg',
      exampleTr: 'Pilotlar saatlerini zulu zamanına göre ayarlar.',
      exampleEn: 'Pilots set their clocks to zulu time.',
    ),
  ];

  static final Map<String, PhoneticLetter> _byLetter = {
    for (final p in all) p.letter: p,
  };

  static PhoneticLetter? forLetter(String letter) =>
      _byLetter[letter.toUpperCase()];
}
