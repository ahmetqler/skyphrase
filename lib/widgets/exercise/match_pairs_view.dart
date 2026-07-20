import 'dart:math';
import 'package:flutter/material.dart';
import '../../l10n/strings.dart';
import '../../models/exercise.dart';
import '../../services/sound_service.dart';
import '../../theme/app_colors.dart';
import '../primary_button.dart';

class MatchPairsView extends StatefulWidget {
  final Exercise exercise;
  final void Function(bool isCorrect) onResult;

  const MatchPairsView({
    super.key,
    required this.exercise,
    required this.onResult,
  });

  @override
  State<MatchPairsView> createState() => _MatchPairsViewState();
}

class _MatchPairsViewState extends State<MatchPairsView> {
  late List<MatchPair> _pairs;
  late List<String> _leftItems;
  late List<String> _rightItems;

  final Set<String> _matched = {}; // eşleşen değerler (left+right)
  String? _selectedLeft;
  String? _selectedRight;
  String? _wrongLeft;
  String? _wrongRight;
  bool _hadMistake = false;

  @override
  void initState() {
    super.initState();
    _pairs = widget.exercise.pairs;
    _leftItems = _pairs.map((e) => e.left).toList()..shuffle(Random());
    _rightItems = _pairs.map((e) => e.right).toList()..shuffle(Random());
  }

  bool get _allMatched => _matched.length == _pairs.length * 2;

  void _tryMatch() {
    if (_selectedLeft == null || _selectedRight == null) return;
    final isPair = _pairs.any(
      (p) => p.left == _selectedLeft && p.right == _selectedRight,
    );
    if (isPair) {
      SoundService.instance.playCorrect();
      setState(() {
        _matched.add('L:$_selectedLeft');
        _matched.add('R:$_selectedRight');
        _selectedLeft = null;
        _selectedRight = null;
      });
    } else {
      SoundService.instance.playWrong();
      _hadMistake = true;
      setState(() {
        _wrongLeft = _selectedLeft;
        _wrongRight = _selectedRight;
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() {
          _wrongLeft = null;
          _wrongRight = null;
          _selectedLeft = null;
          _selectedRight = null;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.exercise.prompt,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _column(_leftItems, isLeft: true)),
                const SizedBox(width: 16),
                Expanded(child: _column(_rightItems, isLeft: false)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: SafeArea(
            top: false,
            child: _allMatched
                ? PrimaryButton(
                    label: Strings.continueLabel,
                    color: AppColors.correct,
                    onPressed: () => widget.onResult(!_hadMistake),
                  )
                : const SizedBox(height: 4),
          ),
        ),
      ],
    );
  }

  Widget _column(List<String> items, {required bool isLeft}) {
    return Column(
      children: items.map((item) {
        final key = isLeft ? 'L:$item' : 'R:$item';
        final matched = _matched.contains(key);
        final selected =
            isLeft ? _selectedLeft == item : _selectedRight == item;
        final wrong = isLeft ? _wrongLeft == item : _wrongRight == item;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _MatchTile(
            label: item,
            matched: matched,
            selected: selected,
            wrong: wrong,
            onTap: matched
                ? null
                : () {
                    setState(() {
                      if (isLeft) {
                        _selectedLeft = item;
                      } else {
                        _selectedRight = item;
                      }
                    });
                    _tryMatch();
                  },
          ),
        );
      }).toList(),
    );
  }
}

class _MatchTile extends StatelessWidget {
  final String label;
  final bool matched;
  final bool selected;
  final bool wrong;
  final VoidCallback? onTap;

  const _MatchTile({
    required this.label,
    required this.matched,
    required this.selected,
    required this.wrong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color border = AppColors.border;
    Color bg = AppColors.surface;
    Color text = AppColors.textPrimary;

    if (matched) {
      border = AppColors.border;
      bg = AppColors.background;
      text = AppColors.locked;
    } else if (wrong) {
      border = AppColors.wrong;
      bg = AppColors.wrongBg;
    } else if (selected) {
      border = AppColors.primary;
      bg = AppColors.primarySoft;
    }

    return Opacity(
      opacity: matched ? 0.5 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border, width: 2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
