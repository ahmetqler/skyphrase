import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/phonetic_alphabet.dart';
import '../services/sound_service.dart';
import '../theme/app_colors.dart';

/// Bir ICAO harfini elle çizilmiş illüstrasyonuyla gösteren görsel kart.
/// İllüstrasyon zaten harf, kod kelimesi ve telaffuzu içerdiğinden ayrıca
/// metin eklemiyoruz — hem ders içi öğretici kartlarda hem de Alfabe
/// sekmesinde aynı görsel kullanılır, tekrar edince akılda daha iyi kalır.
/// Tıklanınca büyütülmüş halini gösterir.
class PhoneticLetterCard extends StatelessWidget {
  final PhoneticLetter letter;
  final double width;

  const PhoneticLetterCard({
    super.key,
    required this.letter,
    this.width = 96,
  });

  void _openDetail(BuildContext context) {
    SoundService.instance.playClick();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                width: 280,
                child: AspectRatio(
                  aspectRatio: 410 / 600,
                  child: SvgPicture.asset(letter.imageAsset, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: 280,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: letter.color.withValues(alpha: 0.35), width: 1.5),
              ),
              child: Text(
                letter.example,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openDetail(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: width,
          decoration: BoxDecoration(
            border: Border.all(color: letter.color.withValues(alpha: 0.35), width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: AspectRatio(
            aspectRatio: 410 / 600,
            child: SvgPicture.asset(letter.imageAsset, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
