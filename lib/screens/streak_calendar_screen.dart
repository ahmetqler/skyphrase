import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/strings.dart';
import '../services/sound_service.dart';
import '../state/progress_provider.dart';
import '../theme/app_colors.dart';

/// Duolingo tarzı seri takvimi: solda büyük seri sayısı, sağda ay ay
/// gezilebilen mini bir takvim. Uçan uçak arka planı artık uygulama
/// genelinde MaterialApp.builder içinde gösteriliyor (bkz. app.dart,
/// FlightTrailsBackground), bu ekranda ayrıca eklemeye gerek yok. Aktif
/// gün verisi için bkz. ProgressProvider.wasActiveOn.
class StreakCalendarScreen extends StatefulWidget {
  const StreakCalendarScreen({super.key});

  @override
  State<StreakCalendarScreen> createState() => _StreakCalendarScreenState();
}

class _StreakCalendarScreenState extends State<StreakCalendarScreen> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  void _shiftMonth(int delta) {
    SoundService.instance.playClick();
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 9, child: _StreakBigNumber(streak: progress.streak)),
                    Expanded(
                      flex: 11,
                      child: _MiniMonthCalendar(
                        visibleMonth: _visibleMonth,
                        onPrev: () => _shiftMonth(-1),
                        onNext: () => _shiftMonth(1),
                        wasActiveOn: progress.wasActiveOn,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakBigNumber extends StatelessWidget {
  final int streak;
  const _StreakBigNumber({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Strings.streakWordLabel,
          style: TextStyle(
            fontFamily: 'serif',
            fontStyle: FontStyle.italic,
            fontSize: 17,
            letterSpacing: 0.4,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$streak',
          style: TextStyle(
            fontFamily: 'serif',
            fontWeight: FontWeight.w700,
            fontSize: 76,
            height: 1.0,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Icon(Icons.local_fire_department, color: AppColors.accent, size: 22),
      ],
    );
  }
}

class _MiniMonthCalendar extends StatelessWidget {
  final DateTime visibleMonth;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final bool Function(DateTime day) wasActiveOn;

  const _MiniMonthCalendar({
    required this.visibleMonth,
    required this.onPrev,
    required this.onNext,
    required this.wasActiveOn,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstOfMonth = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final daysInMonth = DateTime(visibleMonth.year, visibleMonth.month + 1, 0).day;
    final leadingBlanks = firstOfMonth.weekday % 7; // Sun=0..Sat=6

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize: 18,
              icon: Icon(Icons.chevron_left, color: AppColors.textSecondary),
              onPressed: onPrev,
            ),
            Text(
              '${Strings.monthName(visibleMonth.month)} ${visibleMonth.year}',
              style: TextStyle(
                fontFamily: 'serif',
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
            IconButton(
              iconSize: 18,
              icon: Icon(Icons.chevron_right, color: AppColors.textSecondary),
              onPressed: onNext,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            for (final w in Strings.weekdayInitials)
              Expanded(
                child: Center(
                  child: Text(
                    w,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          itemCount: leadingBlanks + daysInMonth,
          itemBuilder: (_, i) {
            if (i < leadingBlanks) return const SizedBox.shrink();
            final day = i - leadingBlanks + 1;
            final date = DateTime(visibleMonth.year, visibleMonth.month, day);
            final isFuture = date.isAfter(today);
            final active = !isFuture && wasActiveOn(date);
            final isToday = date == today;
            return _DayCell(day: day, active: active, isToday: isToday);
          },
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool active;
  final bool isToday;

  const _DayCell({required this.day, required this.active, required this.isToday});

  @override
  Widget build(BuildContext context) {
    final Color? bg = isToday
        ? AppColors.accent
        : active
            ? AppColors.accent.withValues(alpha: 0.22)
            : null;
    final Color textColor = isToday
        ? Colors.white
        : active
            ? AppColors.accent
            : AppColors.textPrimary;

    return Center(
      child: Container(
        width: 22,
        height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isToday || active ? FontWeight.w800 : FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
