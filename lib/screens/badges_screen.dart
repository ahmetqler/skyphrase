import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/badge_def.dart';
import '../l10n/strings.dart';
import '../state/course_provider.dart';
import '../state/progress_provider.dart';
import '../state/settings_provider.dart';
import '../theme/app_colors.dart';

/// İlerledikçe açılan başarı rozetlerini gösteren sekme. Kilit durumu
/// ProgressProvider'ın anlık istatistiklerinden hesaplanır (bkz. BadgeDef),
/// bu yüzden ekstra bir veri kaydına gerek yoktur.
class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();
    final progress = context.watch<ProgressProvider>();
    final course = context.watch<CourseProvider>().course;
    final badges = Badges.all();
    final unlockedCount =
        badges.where((b) => b.isUnlocked(progress, course)).length;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                Icon(Icons.emoji_events, color: AppColors.primary, size: 28),
                const SizedBox(width: 8),
                Text(
                  Strings.tabBadges,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '$unlockedCount/${badges.length}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
            child: Text(
              Strings.badgesSubtitle,
              style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.92,
              ),
              itemCount: badges.length,
              itemBuilder: (_, i) => _BadgeCard(
                  badge: badges[i], unlocked: badges[i].isUnlocked(progress, course)),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final BadgeDef badge;
  final bool unlocked;
  const _BadgeCard({required this.badge, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    final color = unlocked ? badge.color : AppColors.locked;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: unlocked ? badge.color.withValues(alpha: 0.35) : AppColors.border,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darken(color, 0.25),
                      blurRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(badge.icon, color: Colors.white, size: 28),
              ),
              if (!unlocked)
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  margin: const EdgeInsets.only(left: 40, top: 40),
                  child: Icon(Icons.lock, size: 12, color: AppColors.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: unlocked ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            badge.description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.3),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: unlocked
                  ? badge.color.withValues(alpha: 0.16)
                  : AppColors.border.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              unlocked ? Strings.badgeUnlocked : Strings.badgeLocked,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
                color: unlocked ? badge.color : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
