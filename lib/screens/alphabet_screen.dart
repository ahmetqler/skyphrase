import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/phonetic_alphabet.dart';
import '../l10n/strings.dart';
import '../state/settings_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/phonetic_letter_card.dart';

/// A'dan Z'ye tüm ICAO fonetik alfabesini her zaman gözden geçirebileceğin
/// referans sekmesi. Derslerdeki aynı görsel kartları kullanır, böylece
/// ders sırasında gördüğün görsel burada da karşına çıkar.
class AlphabetScreen extends StatelessWidget {
  const AlphabetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                Icon(Icons.abc, color: AppColors.primary, size: 28),
                const SizedBox(width: 8),
                Text(
                  Strings.tabAlphabet,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
            child: Text(
              Strings.alphabetSubtitle,
              style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 410 / 600,
              ),
              itemCount: PhoneticAlphabet.all.length,
              itemBuilder: (_, i) => PhoneticLetterCard(
                letter: PhoneticAlphabet.all[i],
                width: double.infinity,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
