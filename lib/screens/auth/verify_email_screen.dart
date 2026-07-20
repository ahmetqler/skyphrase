import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/strings.dart';
import '../../state/auth_provider.dart';
import '../../state/settings_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/primary_button.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _checking = false;
  bool _resent = false;
  String? _notice;

  Future<void> _checkVerified() async {
    setState(() {
      _checking = true;
      _notice = null;
    });
    final auth = context.read<AuthProvider>();
    await auth.refreshVerificationStatus();
    if (!mounted) return;
    setState(() {
      _checking = false;
      if (!auth.isVerified) _notice = Strings.stillNotVerified;
    });
  }

  Future<void> _resend() async {
    await context.read<AuthProvider>().resendVerificationEmail();
    if (!mounted) return;
    setState(() => _resent = true);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mark_email_unread_outlined,
                  size: 88, color: AppColors.primary),
              const SizedBox(height: 20),
              Text(
                Strings.verifyEmailTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                Strings.verifyEmailBody(auth.email ?? ''),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
              ),
              if (_notice != null) ...[
                const SizedBox(height: 14),
                Text(_notice!, style: TextStyle(color: AppColors.wrong)),
              ],
              if (_resent) ...[
                const SizedBox(height: 14),
                Text(Strings.emailResent, style: TextStyle(color: AppColors.correct)),
              ],
              const SizedBox(height: 28),
              PrimaryButton(
                label: Strings.iVerified,
                onPressed: _checking ? null : _checkVerified,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _resend,
                child: Text(Strings.resendEmail,
                    style: TextStyle(color: AppColors.primary)),
              ),
              TextButton(
                onPressed: () => context.read<AuthProvider>().signOut(),
                child: Text(Strings.signOut,
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
