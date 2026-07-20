import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/strings.dart';
import '../models/course.dart';
import '../services/sound_service.dart';
import '../state/course_provider.dart';
import '../state/progress_provider.dart';
import '../state/settings_provider.dart';
import '../theme/app_colors.dart';
import 'lesson_screen.dart';
import 'streak_calendar_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();
    final courseProvider = context.watch<CourseProvider>();

    if (courseProvider.loading || !context.watch<ProgressProvider>().isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (courseProvider.error != null || courseProvider.course == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('${Strings.contentLoadError}${courseProvider.error}'),
        ),
      );
    }

    final course = courseProvider.course!;
    return SafeArea(
      child: Column(
        children: [
          const _StatsHeader(),
          Expanded(child: _PathList(course: course)),
        ],
      ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  const _StatsHeader();

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              SoundService.instance.playClick();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StreakCalendarScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
              child: _pill(Icons.local_fire_department, '${progress.streak}',
                  AppColors.accent),
            ),
          ),
          const SizedBox(width: 12),
          _pill(Icons.bolt, '${progress.xp}', AppColors.primary),
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _PathList extends StatelessWidget {
  final Course course;
  const _PathList({required this.course});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final flat = course.allLessons;

    // Bir dersin açık olması için ya ilk ders olması ya da bir öncekinin
    // tamamlanmış olması gerekir.
    bool isUnlocked(Lesson lesson) {
      final idx = flat.indexOf(lesson);
      if (idx <= 0) return true;
      return progress.isLessonCompleted(flat[idx - 1].id);
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        for (final unit in course.units) ...[
          _UnitBanner(unit: unit),
          for (var i = 0; i < unit.lessons.length; i++)
            _LessonNode(
              lesson: unit.lessons[i],
              index: i,
              completed: progress.isLessonCompleted(unit.lessons[i].id),
              unlocked: isUnlocked(unit.lessons[i]),
            ),
        ],
      ],
    );
  }
}

class _UnitBanner extends StatelessWidget {
  final Unit unit;
  const _UnitBanner({required this.unit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 28, 16, 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darken(AppColors.primaryDark, 0.18),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.radar, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unit.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (unit.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    unit.subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonNode extends StatelessWidget {
  final Lesson lesson;
  final int index;
  final bool completed;
  final bool unlocked;

  const _LessonNode({
    required this.lesson,
    required this.index,
    required this.completed,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    // Hafif zig-zag hizalama.
    final alignment = switch (index % 4) {
      0 => 0.0,
      1 => 0.4,
      2 => 0.0,
      _ => -0.4,
    };

    final Color bg = completed
        ? AppColors.correct
        : unlocked
            ? AppColors.primary
            : AppColors.locked;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Align(
        alignment: Alignment(alignment, 0),
        child: Column(
          children: [
            GestureDetector(
              onTap: unlocked
                  ? () {
                      SoundService.instance.playClick();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LessonScreen(lesson: lesson),
                        ),
                      );
                    }
                  : null,
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darken(bg, 0.28),
                      blurRadius: 0,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  completed
                      ? Icons.check
                      : unlocked
                          ? Icons.star
                          : Icons.lock,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 140,
              child: Text(
                lesson.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: unlocked
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
