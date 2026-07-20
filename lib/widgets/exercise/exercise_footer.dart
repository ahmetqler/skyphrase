import 'package:flutter/material.dart';
import '../../l10n/strings.dart';
import '../../theme/app_colors.dart';
import '../primary_button.dart';

/// Egzersizlerin altında görünen "Kontrol Et / Devam" alanı.
/// checked=false iken "Kontrol Et", checked=true iken doğru/yanlış geri
/// bildirimi + "Devam" gösterir.
class ExerciseFooter extends StatelessWidget {
  final bool checked;
  final bool? isCorrect;
  final bool canCheck;
  final String? correctionText; // yanlışta gösterilecek doğru cevap
  final VoidCallback onCheck;
  final VoidCallback onContinue;

  const ExerciseFooter({
    super.key,
    required this.checked,
    required this.isCorrect,
    required this.canCheck,
    required this.onCheck,
    required this.onContinue,
    this.correctionText,
  });

  @override
  Widget build(BuildContext context) {
    final correct = isCorrect == true;
    final bg = !checked
        ? Colors.transparent
        : (correct ? AppColors.correctBg : AppColors.wrongBg);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: bg,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (checked) ...[
              Row(
                children: [
                  Icon(
                    correct ? Icons.check_circle : Icons.cancel,
                    color: correct ? AppColors.correct : AppColors.wrong,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    correct ? Strings.correctFeedback : Strings.correctAnswerLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: correct ? AppColors.correct : AppColors.wrong,
                    ),
                  ),
                ],
              ),
              if (!correct && correctionText != null) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Text(
                    correctionText!,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.wrong,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],
            checked
                ? PrimaryButton(
                    label: Strings.continueLabel,
                    onPressed: onContinue,
                    color: correct ? AppColors.correct : AppColors.wrong,
                  )
                : PrimaryButton(
                    label: Strings.checkLabel,
                    onPressed: canCheck ? onCheck : null,
                  ),
          ],
        ),
      ),
    );
  }
}
