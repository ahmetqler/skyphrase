import 'exercise.dart';

class Lesson {
  final String id;
  final String title;
  final List<Exercise> exercises;

  const Lesson({
    required this.id,
    required this.title,
    required this.exercises,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'] as String,
        title: json['title'] as String,
        exercises: (json['exercises'] as List)
            .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class Unit {
  final String id;
  final String title;
  final String subtitle;
  final List<Lesson> lessons;

  const Unit({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.lessons,
  });

  factory Unit.fromJson(Map<String, dynamic> json) => Unit(
        id: json['id'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String? ?? '',
        lessons: (json['lessons'] as List)
            .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class Course {
  final String id;
  final String title;
  final List<Unit> units;

  const Course({
    required this.id,
    required this.title,
    required this.units,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'] as String,
        title: json['title'] as String,
        units: (json['units'] as List)
            .map((e) => Unit.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Kurstaki tüm dersleri sıralı, düz bir liste olarak döner (ilerleme takibi için).
  List<Lesson> get allLessons =>
      [for (final u in units) ...u.lessons];
}
