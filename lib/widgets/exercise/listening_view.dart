import 'package:flutter/material.dart';
import '../../l10n/strings.dart';
import '../../models/exercise.dart';
import '../../services/sound_service.dart';
import '../../services/tts_service.dart';
import '../../theme/app_colors.dart';
import 'exercise_footer.dart';

/// Dinleme egzersizi: metin gösterilmez, cihaz İngilizce ifadeyi
/// seslendirir (bkz. TtsService). Kullanıcı istediği kadar tekrar
/// dinleyebilir, sonra doğru anlamı seçer.
class ListeningView extends StatefulWidget {
  final Exercise exercise;
  final void Function(bool isCorrect) onResult;

  const ListeningView({
    super.key,
    required this.exercise,
    required this.onResult,
  });

  @override
  State<ListeningView> createState() => _ListeningViewState();
}

class _ListeningViewState extends State<ListeningView> {
  int? _selected;
  bool _checked = false;

  bool get _isCorrect => _selected == widget.exercise.correctIndex;

  void _play() {
    SoundService.instance.playClick();
    TtsService.instance.speak(widget.exercise.audioText);
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
                Strings.listeningPrompt,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 28),
              Center(
                child: InkWell(
                  onTap: _play,
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darken(AppColors.primary, 0.25),
                          blurRadius: 0,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.volume_up, color: Colors.white, size: 42),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  Strings.tapToListen,
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 28),
              ...List.generate(ex.options.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _OptionTile(
                    label: ex.options[i],
                    state: _tileState(i),
                    onTap: _checked ? null : () => setState(() => _selected = i),
                  ),
                );
              }),
            ],
          ),
        ),
        ExerciseFooter(
          checked: _checked,
          isCorrect: _checked ? _isCorrect : null,
          canCheck: _selected != null,
          correctionText: ex.options[ex.correctIndex],
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

  _TileState _tileState(int i) {
    if (!_checked) {
      return _selected == i ? _TileState.selected : _TileState.idle;
    }
    if (i == widget.exercise.correctIndex) return _TileState.correct;
    if (i == _selected) return _TileState.wrong;
    return _TileState.idle;
  }
}

enum _TileState { idle, selected, correct, wrong }

class _OptionTile extends StatelessWidget {
  final String label;
  final _TileState state;
  final VoidCallback? onTap;

  const _OptionTile({
    required this.label,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    late Color border;
    late Color bg;
    switch (state) {
      case _TileState.idle:
        border = AppColors.border;
        bg = AppColors.surface;
        break;
      case _TileState.selected:
        border = AppColors.primary;
        bg = AppColors.primarySoft;
        break;
      case _TileState.correct:
        border = AppColors.correct;
        bg = AppColors.correctBg;
        break;
      case _TileState.wrong:
        border = AppColors.wrong;
        bg = AppColors.wrongBg;
        break;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: 2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: border,
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
