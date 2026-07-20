import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../theme/app_colors.dart';
import '../widgets/sky_clock_planes.dart';

/// Tek amacı arka planda uçan uçakları (bkz. FlightTrailsBackground,
/// app.dart üzerinden tüm uygulamanın arkasında zaten çalışıyor) izlemek
/// olan bir sekme. Buna ek olarak, sadece bu ekrana özel birkaç uçak
/// (bkz. SkyClockPlanes) izleriyle o anki saati sürekli güncel çizer.
/// Kendi Scaffold'u yok — HomeShell'in üst Scaffold'unun body'sini
/// paylaşır, bu yüzden tamamen şeffaf kalıp arkadaki uçakların tam ekran
/// görünmesini sağlar.
class SkyWatchScreen extends StatelessWidget {
  const SkyWatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned.fill(child: SkyClockPlanes()),
        Positioned(
          left: 0,
          right: 0,
          bottom: 28,
          child: _SkyWatchHint(),
        ),
      ],
    );
  }
}

class _SkyWatchHint extends StatelessWidget {
  const _SkyWatchHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        Strings.skyWatchHint,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
