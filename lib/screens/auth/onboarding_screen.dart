import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/strings.dart';
import '../../services/sound_service.dart';
import '../../state/progress_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/primary_button.dart';

class _OnboardPage {
  final IconData icon;
  final String title;
  final String body;
  const _OnboardPage({required this.icon, required this.title, required this.body});
}

/// Hesap oluşturup parkur seçtikten sonra bir kez gösterilen kısa tanıtım
/// turu: sekmelerin ve üst bardaki simgelerin ne işe yaradığını anlatır.
/// Görüldüğü hesaba kaydedilir (bkz. ProgressProvider.completeOnboarding),
/// bir daha giriş yapılınca tekrar çıkmaz.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  List<_OnboardPage> get _pages => [
        _OnboardPage(
          icon: Icons.flight_takeoff,
          title: Strings.onboardWelcomeTitle,
          body: Strings.onboardWelcomeBody,
        ),
        _OnboardPage(
          icon: Icons.map_outlined,
          title: Strings.onboardLearnTitle,
          body: Strings.onboardLearnBody,
        ),
        _OnboardPage(
          icon: Icons.abc,
          title: Strings.onboardAlphabetTitle,
          body: Strings.onboardAlphabetBody,
        ),
        _OnboardPage(
          icon: Icons.psychology_alt_outlined,
          title: Strings.onboardReviewTitle,
          body: Strings.onboardReviewBody,
        ),
        _OnboardPage(
          icon: Icons.people_alt_outlined,
          title: Strings.onboardFriendsTitle,
          body: Strings.onboardFriendsBody,
        ),
      ];

  bool get _isLastPage => _page == _pages.length - 1;

  void _finish() {
    context.read<ProgressProvider>().completeOnboarding();
  }

  void _skip() {
    SoundService.instance.playClick();
    _finish();
  }

  void _next() {
    if (_isLastPage) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 12, 0),
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    Strings.onboardSkip,
                    style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(page.icon, color: AppColors.primary, size: 44),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == _page ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: PrimaryButton(
                label: _isLastPage ? Strings.onboardStart : Strings.onboardNext,
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
