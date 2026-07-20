import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/strings.dart';
import '../models/course.dart';
import '../models/exercise.dart';
import '../state/lesson_session.dart';
import '../state/mistakes_provider.dart';
import '../state/progress_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/lesson_top_bar.dart';
import '../widgets/exercise/multiple_choice_view.dart';
import '../widgets/exercise/match_pairs_view.dart';
import '../widgets/exercise/word_bank_view.dart';
import '../widgets/exercise/fill_blank_view.dart';
import '../widgets/exercise/info_card_view.dart';
import '../widgets/exercise/listening_view.dart';
import 'result_screen.dart';

class LessonScreen extends StatelessWidget {
  final Lesson lesson;
  const LessonScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LessonSession(lesson),
      child: const _LessonView(),
    );
  }
}

class _LessonView extends StatelessWidget {
  const _LessonView();

  /// Bu oranın altında kalan dersler geçilmiş sayılmaz, tekrar edilmesi
  /// gerekir (kullanıcı isteği: belirli bir eşiği geçemeyince tekrar).
  static const double passThreshold = 0.6;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<LessonSession>();

    if (session.isFinished) {
      // Ders bitti: hataları tekrar kuyruğuna ekle, eşiği geçtiyse
      // ilerlemeyi kaydet, geçemediyse tekrar denemesi için yönlendir.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final progress = context.read<ProgressProvider>();
        final mistakes = context.read<MistakesProvider>();
        mistakes.recordLessonResults(session.lesson.id, session.results);

        final passed = session.accuracy >= passThreshold;
        if (passed) {
          progress.completeLesson(session.lesson.id,
              earnedXp: session.earnedXp);
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              earnedXp: passed ? session.earnedXp : 0,
              correct: session.correct,
              total: session.gradedTotal,
              passed: passed,
              passThresholdPercent: (passThreshold * 100).round(),
              onRetry: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => LessonScreen(lesson: session.lesson),
                ),
              ),
            ),
          ),
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            LessonTopBar(
              progress: session.progress,
              onClose: () => _confirmQuit(context),
            ),
            Expanded(
              // Her egzersizde state sıfırlansın diye ValueKey kullanıyoruz.
              child: KeyedSubtree(
                key: ValueKey(session.index),
                child: _buildExercise(context, session),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExercise(BuildContext context, LessonSession session) {
    final ex = session.current;
    void onResult(bool isCorrect) {
      session.submitResult(isCorrect: isCorrect);
      session.next();
    }

    switch (ex.type) {
      case ExerciseType.info:
        return InfoCardView(exercise: ex, onContinue: session.next);
      case ExerciseType.multipleChoice:
        return MultipleChoiceView(exercise: ex, onResult: onResult);
      case ExerciseType.matchPairs:
        return MatchPairsView(exercise: ex, onResult: onResult);
      case ExerciseType.wordBank:
        return WordBankView(exercise: ex, onResult: onResult);
      case ExerciseType.fillBlank:
        return FillBlankView(exercise: ex, onResult: onResult);
      case ExerciseType.listening:
        return ListeningView(exercise: ex, onResult: onResult);
    }
  }

  void _confirmQuit(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(Strings.quitLessonTitle),
        content: Text(Strings.quitLessonBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(Strings.keepGoing),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              Navigator.of(context).pop();
            },
            child: Text(Strings.quit,
                style: TextStyle(color: AppColors.wrong)),
          ),
        ],
      ),
    );
  }
}
