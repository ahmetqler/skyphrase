import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auth_provider.dart';
import '../../state/progress_provider.dart';
import '../home_shell.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import 'track_selection_screen.dart';
import 'verify_email_screen.dart';

/// Uygulamanın gerçek giriş noktası: kimlik doğrulama durumuna göre
/// giriş ekranı, e-posta onay ekranı, parkur seçimi ya da asıl
/// uygulamayı (HomeShell) gösterir.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!auth.isLoggedIn) {
      return const LoginScreen();
    }
    if (!auth.isVerified) {
      return const VerifyEmailScreen();
    }

    final progress = context.watch<ProgressProvider>();
    if (!progress.isLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (progress.track == null) {
      return const TrackSelectionScreen();
    }
    if (!progress.onboardingSeen) {
      return const OnboardingScreen();
    }
    return const HomeShell();
  }
}
