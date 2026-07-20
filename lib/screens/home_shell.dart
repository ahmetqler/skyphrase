import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/strings.dart';
import '../services/sound_service.dart';
import '../state/settings_provider.dart';
import '../theme/app_colors.dart';
import 'alphabet_screen.dart';
import 'badges_screen.dart';
import 'friends_screen.dart';
import 'home_screen.dart';
import 'review_screen.dart';
import 'settings_screen.dart';
import 'sky_watch_screen.dart';

/// Uygulamanın alt sekme çubuğu (Instagram tarzı): Öğren, Alfabe, Tekrar
/// Çalış, Arkadaşlar. Üstte, her sekmede sabit kalan bir ayarlar simgesi
/// var (sağ üst köşe). Her sekme kendi Scaffold'unu değil, tek bir üst
/// Scaffold'un body'sini paylaşır.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  List<Widget> get _screens => [
        const HomeScreen(),
        const AlphabetScreen(),
        const ReviewScreen(),
        const FriendsScreen(),
        const BadgesScreen(),
        const SkyWatchScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    // Dil/tema değiştiğinde bu ağacın yeniden çizilmesini garanti eder.
    context.watch<SettingsProvider>();

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 12, 4),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      SoundService.instance.playClick();
                      setState(() => _index = 0);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.flight, color: AppColors.primary, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Skyphrase',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.settings_outlined,
                        color: AppColors.textSecondary),
                    onPressed: () {
                      SoundService.instance.playClick();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: IndexedStack(index: _index, children: _screens)),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) {
              SoundService.instance.playClick();
              setState(() => _index = i);
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.map_outlined),
                activeIcon: const Icon(Icons.map),
                label: Strings.tabLearn,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.abc),
                label: Strings.tabAlphabet,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.psychology_alt_outlined),
                activeIcon: const Icon(Icons.psychology_alt),
                label: Strings.tabReview,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.people_alt_outlined),
                activeIcon: const Icon(Icons.people_alt),
                label: Strings.tabFriends,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.emoji_events_outlined),
                activeIcon: const Icon(Icons.emoji_events),
                label: Strings.tabBadges,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.flight_outlined),
                activeIcon: const Icon(Icons.flight),
                label: Strings.tabSky,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
