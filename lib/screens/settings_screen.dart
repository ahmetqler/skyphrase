import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/aviation_track.dart';
import '../l10n/strings.dart';
import '../state/auth_provider.dart';
import '../state/progress_provider.dart';
import '../state/settings_provider.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();
    final progress = context.watch<ProgressProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(Strings.settingsTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            Strings.languageLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _LanguageTile(
                  label: Strings.turkish,
                  flag: '🇹🇷',
                  selected: settings.language == AppLanguage.tr,
                  onTap: () => settings.setLanguage(AppLanguage.tr),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LanguageTile(
                  label: Strings.english,
                  flag: '🇬🇧',
                  selected: settings.language == AppLanguage.en,
                  onTap: () => settings.setLanguage(AppLanguage.en),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            Strings.themeLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          _ThemeTile(
            label: Strings.themeBlue,
            variant: AppThemeVariant.blue,
            selected: settings.themeVariant == AppThemeVariant.blue,
            swatchBg: const Color(0xFF0E1626),
            swatchAccent: const Color(0xFF4C9AFF),
            onTap: () => settings.setThemeVariant(AppThemeVariant.blue),
          ),
          const SizedBox(height: 12),
          _ThemeTile(
            label: Strings.themeBlack,
            variant: AppThemeVariant.black,
            selected: settings.themeVariant == AppThemeVariant.black,
            swatchBg: const Color(0xFF000000),
            swatchAccent: const Color(0xFF4FA8FF),
            onTap: () => settings.setThemeVariant(AppThemeVariant.black),
          ),
          const SizedBox(height: 12),
          _ThemeTile(
            label: Strings.themeLight,
            variant: AppThemeVariant.light,
            selected: settings.themeVariant == AppThemeVariant.light,
            swatchBg: const Color(0xFFFAFBFF),
            swatchAccent: const Color(0xFF3478E0),
            onTap: () => settings.setThemeVariant(AppThemeVariant.light),
          ),
          const SizedBox(height: 12),
          _ThemeTile(
            label: Strings.themePink,
            variant: AppThemeVariant.pink,
            selected: settings.themeVariant == AppThemeVariant.pink,
            swatchBg: const Color(0xFFF6C9DD),
            swatchAccent: const Color(0xFFFF5FA2),
            onTap: () => settings.setThemeVariant(AppThemeVariant.pink),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                Strings.soundLabel,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                Strings.soundSubtitle,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              value: settings.soundEnabled,
              activeThumbColor: AppColors.primary,
              onChanged: (v) => settings.setSoundEnabled(v),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            Strings.learningTrackLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            Strings.changeTrackWarning,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
          ),
          const SizedBox(height: 10),
          for (final track in AviationTrack.values) ...[
            _TrackTile(
              track: track,
              selected: progress.track == track,
              onTap: () => progress.chooseTrack(track),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 18),
          Text(
            Strings.account,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.account_circle, color: AppColors.textSecondary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Strings.loggedInAs,
                        style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                      Text(
                        auth.email ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => auth.signOut(),
                  child: Text(Strings.signOut,
                      style: TextStyle(color: AppColors.wrong)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String label;
  final String flag;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.label,
    required this.flag,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(flag, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackTile extends StatelessWidget {
  final AviationTrack track;
  final bool selected;
  final VoidCallback onTap;

  const _TrackTile({
    required this.track,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(track.icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    track.description,
                    style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final String label;
  final AppThemeVariant variant;
  final bool selected;
  final Color swatchBg;
  final Color swatchAccent;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.label,
    required this.variant,
    required this.selected,
    required this.swatchBg,
    required this.swatchAccent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: swatchBg,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Center(
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: swatchAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}
