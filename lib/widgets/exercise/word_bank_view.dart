import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/exercise.dart';
import '../../services/sound_service.dart';
import '../../theme/app_colors.dart';
import 'exercise_footer.dart';

class WordBankView extends StatefulWidget {
  final Exercise exercise;
  final void Function(bool isCorrect) onResult;

  const WordBankView({
    super.key,
    required this.exercise,
    required this.onResult,
  });

  @override
  State<WordBankView> createState() => _WordBankViewState();
}

class _WordBankViewState extends State<WordBankView> {
  late List<_Word> _bank;
  final List<_Word> _answer = [];
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    final all = [
      ...widget.exercise.correctOrder,
      ...widget.exercise.distractors,
    ];
    // Her kelimeye benzersiz kimlik ver (tekrarlı kelimeler için).
    _bank = [
      for (var i = 0; i < all.length; i++) _Word(id: i, text: all[i]),
    ]..shuffle(Random());
  }

  bool get _isCorrect {
    final built = _answer.map((w) => w.text).toList();
    final correct = widget.exercise.correctOrder;
    if (built.length != correct.length) return false;
    for (var i = 0; i < built.length; i++) {
      if (built[i] != correct[i]) return false;
    }
    return true;
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
                ),
              ),
              const SizedBox(height: 28),
              // Cevap alanı
              _AnswerArea(
                words: _answer,
                onRemove: _checked
                    ? null
                    : (w) => setState(() {
                          _answer.remove(w);
                          _bank.add(w);
                        }),
              ),
              const SizedBox(height: 28),
              // Kelime bankası
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _bank
                    .map((w) => _Chip(
                          label: w.text,
                          onTap: _checked
                              ? null
                              : () => setState(() {
                                    _bank.remove(w);
                                    _answer.add(w);
                                  }),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        ExerciseFooter(
          checked: _checked,
          isCorrect: _checked ? _isCorrect : null,
          canCheck: _answer.isNotEmpty,
          correctionText: ex.correctOrder.join(' '),
          onCheck: () {
            setState(() => _checked = true);
            _isCorrect
                ? SoundService.instance.playCorrect()
                : SoundService.instance.playWrong();
          },
          onContinue: () => widget.onResult(_isCorrect),
        ),
      ],
    );
  }
}

class _Word {
  final int id;
  final String text;
  const _Word({required this.id, required this.text});
}

class _AnswerArea extends StatelessWidget {
  final List<_Word> words;
  final void Function(_Word)? onRemove;

  const _AnswerArea({required this.words, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border, width: 2),
          bottom: BorderSide(color: AppColors.border, width: 2),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: words
              .map((w) => _Chip(
                    label: w.text,
                    onTap: onRemove == null ? null : () => onRemove!(w),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _Chip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.border,
              blurRadius: 0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
