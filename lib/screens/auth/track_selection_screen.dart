import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/aviation_track.dart';
import '../../l10n/strings.dart';
import '../../state/progress_provider.dart';
import '../../theme/app_colors.dart';

/// Hesaba ilk giriş sonrası (ya da ayarlardan) gösterilen parkur seçim
/// ekranı: kullanıcı hangi havacılık terminolojisini öğrenmek istediğini
/// seçer, bu tercih hesabına kaydedilir.
class TrackSelectionScreen extends StatelessWidget {
  const TrackSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Icon(Icons.flight, color: AppColors.primary, size: 44),
              const SizedBox(height: 16),
              Text(
                Strings.chooseTrackTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                Strings.chooseTrackSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 28),
              for (final track in AviationTrack.values) ...[
                _TrackCard(track: track),
                const SizedBox(height: 14),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  final AviationTrack track;
  const _TrackCard({required this.track});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => context.read<ProgressProvider>().chooseTrack(track),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(track.icon, color: AppColors.primary, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.description,
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.3),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
