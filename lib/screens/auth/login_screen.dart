import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/strings.dart';
import '../../state/auth_provider.dart';
import '../../state/settings_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/primary_button.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    final error = await context.read<AuthProvider>().signIn(
          emailOrUsername: _idController.text,
          password: _passwordController.text,
        );
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _error = error;
    });
  }

  void _showForgotPasswordDialog() {
    final controller = TextEditingController(text: _idController.text.contains('@') ? _idController.text : '');
    showDialog(
      context: context,
      builder: (dialogCtx) {
        String? status;
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text(Strings.resetPasswordTitle,
                style: TextStyle(color: AppColors.textPrimary)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Strings.resetPasswordBody,
                    style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: Strings.email,
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                if (status != null) ...[
                  const SizedBox(height: 8),
                  Text(status!, style: TextStyle(color: AppColors.primary)),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text(Strings.cancel,
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
              TextButton(
                onPressed: () async {
                  final err = await context
                      .read<AuthProvider>()
                      .sendPasswordResetEmail(controller.text);
                  setDialogState(() => status = err ?? Strings.resetEmailSent);
                },
                child: Text(Strings.send, style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.flight, color: AppColors.primary, size: 56),
                const SizedBox(height: 12),
                Text(
                  Strings.welcomeTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  Strings.loginSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _idController,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: _inputDecoration(Strings.emailOrUsername),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: _inputDecoration(Strings.password),
                  onSubmitted: (_) => _submitting ? null : _submit(),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: Text(Strings.forgotPassword,
                        style: TextStyle(color: AppColors.primary)),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 4),
                  Text(_error!, style: TextStyle(color: AppColors.wrong)),
                ],
                const SizedBox(height: 16),
                PrimaryButton(
                  label: Strings.logIn,
                  onPressed: _submitting ? null : _submit,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  ),
                  child: Text(Strings.noAccountYet,
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}
