import 'package:flutter/material.dart';
import '../../l10n/strings.dart';
import '../../models/exercise.dart';
import '../../services/sound_service.dart';
import '../../theme/app_colors.dart';
import 'exercise_footer.dart';

class FillBlankView extends StatefulWidget {
  final Exercise exercise;
  final void Function(bool isCorrect) onResult;

  const FillBlankView({
    super.key,
    required this.exercise,
    required this.onResult,
  });

  @override
  State<FillBlankView> createState() => _FillBlankViewState();
}

class _FillBlankViewState extends State<FillBlankView> {
  final _controller = TextEditingController();
  bool _checked = false;
  bool _isCorrect = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Karşılaştırma için metni sadeleştirir: küçük harf, boşluk/tire/nokta temizliği.
  String _normalize(String s) => s
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r'[\s\-\.]'), '')
      .replaceAll('ı', 'i');

  void _check() {
    final input = _normalize(_controller.text);
    final ok = widget.exercise.answers
        .map(_normalize)
        .any((a) => a == input && input.isNotEmpty);
    setState(() {
      _isCorrect = ok;
      _checked = true;
    });
    ok ? SoundService.instance.playCorrect() : SoundService.instance.playWrong();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                ex.prompt,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _controller,
                autofocus: true,
                enabled: !_checked,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) {
                  if (!_checked && _controller.text.trim().isNotEmpty) {
                    _check();
                  }
                },
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: ex.hint ?? Strings.writeYourAnswer,
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 18),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        BorderSide(color: AppColors.border, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        BorderSide(color: AppColors.primary, width: 2),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: _isCorrect ? AppColors.correct : AppColors.wrong,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ExerciseFooter(
          checked: _checked,
          isCorrect: _checked ? _isCorrect : null,
          canCheck: _controller.text.trim().isNotEmpty,
          correctionText: ex.display,
          onCheck: _check,
          onContinue: () => widget.onResult(_isCorrect),
        ),
      ],
    );
  }
}
