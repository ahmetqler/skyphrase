import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/course_repository.dart';
import 'l10n/strings.dart';
import 'screens/auth/auth_gate.dart';
import 'services/sound_service.dart';
import 'state/auth_provider.dart';
import 'state/course_provider.dart';
import 'state/friends_provider.dart';
import 'state/mistakes_provider.dart';
import 'state/progress_provider.dart';
import 'state/settings_provider.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'widgets/flight_trails_background.dart';

class SkyphraseApp extends StatelessWidget {
  const SkyphraseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProgressProvider>(
          create: (_) => ProgressProvider(),
          update: (ctx, auth, previous) {
            final provider = previous ?? ProgressProvider();
            final uid = auth.isLoggedIn && auth.isVerified ? auth.uid : null;
            if (uid != null) {
              provider.bind(uid);
            } else {
              provider.unbind();
            }
            return provider;
          },
        ),
        ChangeNotifierProxyProvider2<SettingsProvider, ProgressProvider,
            CourseProvider>(
          create: (ctx) => CourseProvider(const CourseRepository()),
          update: (ctx, settings, progress, previous) {
            final provider = previous ?? CourseProvider(const CourseRepository());
            provider.reload(settings.language, progress.track);
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => MistakesProvider()..load(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, FriendsProvider>(
          create: (_) => FriendsProvider(),
          update: (ctx, auth, previous) {
            final provider = previous ?? FriendsProvider();
            final uid = auth.isLoggedIn && auth.isVerified ? auth.uid : null;
            if (uid != null) {
              provider.bind(uid);
            } else {
              provider.unbind();
            }
            return provider;
          },
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          // Global tema/dil durumunu her render öncesi güncelle — böylece
          // aşağıdaki tüm widget'lar AppColors.x / Strings.x okuduğunda
          // güncel değeri görür (bkz. her ekranın context.watch çağrısı).
          AppColors.applyVariant(settings.themeVariant);
          Strings.setLanguage(settings.language);
          SoundService.instance.enabled = settings.soundEnabled;
          return MaterialApp(
            title: 'Skyphrase',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.current,
            // Uçan uçak arka planını tüm ekranların (ders, ayarlar, giriş
            // vb.) arkasında tek bir yerden gösterir — her Scaffold artık
            // şeffaf (bkz. app_theme.dart) ve bunun üzerinde duruyor.
            builder: (context, child) => Stack(
              children: [
                Positioned.fill(child: ColoredBox(color: AppColors.background)),
                const Positioned.fill(
                    child: IgnorePointer(child: FlightTrailsBackground())),
                if (child != null) child,
              ],
            ),
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}
