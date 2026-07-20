import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/phonetic_alphabet.dart';
import '../../data/term_visuals.dart';
import '../../l10n/strings.dart';
import '../../models/exercise.dart';
import '../../theme/app_colors.dart';
import '../primary_button.dart';

/// Öğretici kart: terim ve anlamını gösterir, puanlanmaz. Sınav öncesi
/// öğretir. Birden fazla terim varsa (ör. harf listesi, kelime listesi)
/// hepsini aynı anda göstermek yerine tek tek, büyük bir ikonla gösterir
/// — akılda kalıcılık için (bkz. kullanıcı isteği).
class InfoCardView extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback onContinue;

  const InfoCardView({
    super.key,
    required this.exercise,
    required this.onContinue,
  });

  @override
  State<InfoCardView> createState() => _InfoCardViewState();
}

class _InfoCardViewState extends State<InfoCardView> {
  int _itemIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final hasItems = ex.items.isNotEmpty;
    final isLastItem = !hasItems || _itemIndex == ex.items.length - 1;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      Strings.learnBadge,
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (ex.title.isNotEmpty)
                Text(
                  ex.title,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              if (ex.subtitle.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  ex.subtitle,
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
              if (hasItems) ...[
                const SizedBox(height: 28),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _TermFlashcard(
                    key: ValueKey(_itemIndex),
                    item: ex.items[_itemIndex],
                    index: _itemIndex,
                  ),
                ),
                const SizedBox(height: 16),
                _ProgressDots(total: ex.items.length, current: _itemIndex),
              ],
              if (isLastItem && ex.note.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.4), width: 1.5),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_outline,
                          color: AppColors.accent, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          ex.note,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: SafeArea(
            top: false,
            child: PrimaryButton(
              label: Strings.continueLabel,
              onPressed: () {
                if (!isLastItem) {
                  setState(() => _itemIndex++);
                } else {
                  widget.onContinue();
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Tek bir terimi büyük bir ikonla gösteren kart. Harf ise (ör. "A")
/// PhoneticAlphabet'teki görseli, değilse TermVisuals'daki genel ikonu
/// kullanır — eşleşme yoksa jenerik bir ikona düşer, hiçbir zaman kırılmaz.
class _TermFlashcard extends StatelessWidget {
  final InfoItem item;
  final int index;

  const _TermFlashcard({super.key, required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final letter = PhoneticAlphabet.forLetter(item.k);

    if (letter != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: letter.color.withValues(alpha: 0.35), width: 1.5),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                width: 180,
                child: AspectRatio(
                  aspectRatio: 410 / 600,
                  child: SvgPicture.asset(letter.imageAsset, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Icon(Icons.arrow_downward, size: 16, color: AppColors.locked),
            const SizedBox(height: 8),
            Text(
              item.v,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
          ],
        ),
      );
    }

    final visual = TermVisuals.forTerm(item.k, index);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: visual.color.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: visual.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.darken(visual.color, 0.25),
                  blurRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(visual.icon, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 18),
          Text(
            item.k,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: visual.color,
            ),
          ),
          const SizedBox(height: 8),
          Icon(Icons.arrow_downward, size: 16, color: AppColors.locked),
          const SizedBox(height: 8),
          Text(
            item.v,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  final int total;
  final int current;
  const _ProgressDots({required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == current ? 20 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i == current ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
