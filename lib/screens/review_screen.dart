import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/strings.dart';
import '../state/course_provider.dart';
import '../state/mistakes_provider.dart';
import '../state/settings_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_button.dart';
import 'review_session_screen.dart';

/// Duolingo kullanıcılarının en sık dile getirdiği eksik: derste bir kez
/// yanlış yapılan bir soru bir daha karşına çıkmıyor. Burada tam tersi —
/// yanlış yaptığın her şey otomatik olarak bu kuyruğa düşüyor ve
/// ustalaşana kadar (3 kez üst üste doğru) karşına çıkmaya devam ediyor.
class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();
    final courseProvider = context.watch<CourseProvider>();
    final mistakes = context.watch<MistakesProvider>();

    if (courseProvider.loading || !mistakes.isLoaded || courseProvider.course == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final items = mistakes.resolve(courseProvider.course!);
    final newCount = items.where((i) => i.entry.box == 1).length;
    final learningCount = items.where((i) => i.entry.box == 2).length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology_alt, color: AppColors.primary, size: 26),
                const SizedBox(width: 8),
                Text(
                  Strings.tabReview,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              Strings.reviewSubtitle,
              style: TextStyle(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            if (items.isEmpty)
              const Expanded(child: _EmptyState())
            else ...[
              Row(
                children: [
                  _CountChip(
                      label: Strings.boxNew,
                      value: newCount,
                      color: AppColors.wrong),
                  const SizedBox(width: 10),
                  _CountChip(
                      label: Strings.boxLearning,
                      value: learningCount,
                      color: AppColors.accent),
                  const SizedBox(width: 10),
                  _CountChip(
                      label: Strings.boxAlmostDone,
                      value: items.length - newCount - learningCount,
                      color: AppColors.correct),
                ],
              ),
              const Spacer(),
              PrimaryButton(
                label: Strings.startPractice(items.length),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReviewSessionScreen(items: items),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: 72, color: AppColors.correct),
          const SizedBox(height: 16),
          Text(
            Strings.reviewEmptyTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              Strings.reviewEmptyBody,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _CountChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
