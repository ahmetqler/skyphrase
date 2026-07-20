enum ExerciseType { info, multipleChoice, matchPairs, wordBank, fillBlank, listening }

/// Bir ders içindeki tek bir adım. Tipler:
///  - info: ÖĞRETİCİ kart (puanlanmaz). Terim + anlam gösterir; sınav öncesi öğretir.
///  - multipleChoice: soru + seçenekler.
///  - matchPairs: sol/sağ eşleştirme.
///  - wordBank: kelimeleri doğru sıraya dizme.
///  - fillBlank: cevabı yazma (yazım toleranslı).
///  - listening: İngilizce ifade cihaz tarafından seslendirilir (metin
///    gösterilmez), doğru anlamı seçeneklerden seçersin.
class Exercise {
  final ExerciseType type;
  final String prompt;

  // multipleChoice / listening
  final List<String> options;
  final int correctIndex;

  // listening
  final String audioText;

  // matchPairs
  final List<MatchPair> pairs;

  // wordBank
  final List<String> correctOrder;
  final List<String> distractors;

  // fillBlank
  final List<String> answers;
  final String display;
  final String? hint;

  // info (öğretici kart)
  final String title;
  final String subtitle;
  final String note;
  final List<InfoItem> items;

  const Exercise({
    required this.type,
    this.prompt = '',
    this.options = const [],
    this.correctIndex = 0,
    this.audioText = '',
    this.pairs = const [],
    this.correctOrder = const [],
    this.distractors = const [],
    this.answers = const [],
    this.display = '',
    this.hint,
    this.title = '',
    this.subtitle = '',
    this.note = '',
    this.items = const [],
  });

  /// Bu adım puanlanıyor mu? (info kartları puanlanmaz)
  bool get isGraded => type != ExerciseType.info;

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final type = _typeFromString(json['type'] as String);
    switch (type) {
      case ExerciseType.info:
        return Exercise(
          type: type,
          title: json['title'] as String? ?? '',
          subtitle: json['subtitle'] as String? ?? '',
          note: json['note'] as String? ?? '',
          items: (json['items'] as List?)
                  ?.map((e) => InfoItem.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              const [],
        );
      case ExerciseType.multipleChoice:
        return Exercise(
          type: type,
          prompt: json['prompt'] as String,
          options: (json['options'] as List).cast<String>(),
          correctIndex: json['correctIndex'] as int,
        );
      case ExerciseType.matchPairs:
        return Exercise(
          type: type,
          prompt: json['prompt'] as String? ?? 'Eşleştir',
          pairs: (json['pairs'] as List)
              .map((e) => MatchPair.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      case ExerciseType.wordBank:
        return Exercise(
          type: type,
          prompt: json['prompt'] as String,
          correctOrder: (json['correctOrder'] as List).cast<String>(),
          distractors:
              (json['distractors'] as List?)?.cast<String>() ?? const [],
        );
      case ExerciseType.fillBlank:
        return Exercise(
          type: type,
          prompt: json['prompt'] as String,
          answers: (json['answers'] as List).cast<String>(),
          display: json['display'] as String? ??
              (json['answers'] as List).cast<String>().first,
          hint: json['hint'] as String?,
        );
      case ExerciseType.listening:
        return Exercise(
          type: type,
          audioText: json['audioText'] as String,
          options: (json['options'] as List).cast<String>(),
          correctIndex: json['correctIndex'] as int,
        );
    }
  }

  static ExerciseType _typeFromString(String s) {
    switch (s) {
      case 'info':
        return ExerciseType.info;
      case 'multipleChoice':
        return ExerciseType.multipleChoice;
      case 'matchPairs':
        return ExerciseType.matchPairs;
      case 'wordBank':
        return ExerciseType.wordBank;
      case 'fillBlank':
        return ExerciseType.fillBlank;
      case 'listening':
        return ExerciseType.listening;
      default:
        throw ArgumentError('Bilinmeyen egzersiz tipi: $s');
    }
  }
}

class MatchPair {
  final String left;
  final String right;
  const MatchPair({required this.left, required this.right});
  factory MatchPair.fromJson(Map<String, dynamic> json) => MatchPair(
        left: json['left'] as String,
        right: json['right'] as String,
      );
}

/// Öğretici kartta gösterilen anahtar/değer satırı (ör. "A" -> "Alfa").
class InfoItem {
  final String k;
  final String v;
  const InfoItem({required this.k, required this.v});
  factory InfoItem.fromJson(Map<String, dynamic> json) => InfoItem(
        k: json['k'] as String,
        v: json['v'] as String,
      );
}
