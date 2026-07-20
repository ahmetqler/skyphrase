import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_button.dart';

class ResultScreen extends StatelessWidget {
  final int earnedXp;
  final int correct;
  final int total;
  final bool passed;
  final int passThresholdPercent;
  final VoidCallback? onRetry;
  final String? passedTitle;
  final String? homeLabel;

  const ResultScreen({
    super.key,
    required this.earnedXp,
    required this.correct,
    required this.total,
    this.passed = true,
    this.passThresholdPercent = 60,
    this.onRetry,
    this.passedTitle,
    this.homeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final accuracy = total == 0 ? 0 : (correct / total * 100).round();
    final title = passedTitle ?? Strings.lessonCompleted;
    final home = homeLabel ?? Strings.backToMap;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Icon(
                passed ? Icons.flight_takeoff : Icons.replay_circle_filled,
                size: 96,
                color: passed ? AppColors.primary : AppColors.wrong,
              ),
              const SizedBox(height: 24),
              Text(
                passed ? title : Strings.notThisTime,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              if (!passed) ...[
                const SizedBox(height: 10),
                Text(
                  Strings.failMessage(passThresholdPercent),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Row(
                children: [
                  _StatCard(
                    label: Strings.xpEarnedLabel,
                    value: '+$earnedXp',
                    color: AppColors.accent,
                    icon: Icons.bolt,
                  ),
                  const SizedBox(width: 16),
                  _StatCard(
                    label: Strings.accuracyLabel,
                    value: '%$accuracy',
                    color: passed ? AppColors.correct : AppColors.wrong,
                    icon: Icons.center_focus_strong,
                  ),
                ],
              ),
              const Spacer(),
              PrimaryButton(
                label: passed ? home : Strings.tryAgain,
                color: passed ? null : AppColors.wrong,
                onPressed: passed
                    ? () => Navigator.of(context).pop()
                    : (onRetry ?? () => Navigator.of(context).pop()),
              ),
              if (!passed) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    Strings.backToMapLink,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
