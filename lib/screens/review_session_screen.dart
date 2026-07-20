import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/strings.dart';
import '../models/course.dart';
import '../models/exercise.dart';
import '../state/lesson_session.dart';
import '../state/mistakes_provider.dart';
import '../state/progress_provider.dart';
import '../widgets/lesson_top_bar.dart';
import '../widgets/exercise/multiple_choice_view.dart';
import '../widgets/exercise/match_pairs_view.dart';
import '../widgets/exercise/word_bank_view.dart';
import '../widgets/exercise/fill_blank_view.dart';
import '../widgets/exercise/listening_view.dart';
import 'result_screen.dart';

/// Sadece daha önce yanlış yapılan sorulardan oluşan bir pratik oturumu.
/// Ders akışıyla aynı egzersiz görünümlerini kullanır ama geçme eşiği
/// yoktur ve sonuçlar tekrar kuyruğunu (MistakesProvider) günceller.
class ReviewSessionScreen extends StatelessWidget {
  final List<ReviewItem> items;
  const ReviewSessionScreen({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final lesson = Lesson(
      id: 'review-session',
      title: Strings.tabReview,
      exercises: items.map((i) => i.exercise).toList(),
    );
    return ChangeNotifierProvider(
      create: (_) => LessonSession(lesson),
      child: _ReviewSessionView(items: items),
    );
  }
}

class _ReviewSessionView extends StatelessWidget {
  final List<ReviewItem> items;
  const _ReviewSessionView({required this.items});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<LessonSession>();

    if (session.isFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final mistakes = context.read<MistakesProvider>();
        final progress = context.read<ProgressProvider>();
        for (final entry in session.results.entries) {
          await mistakes.recordReviewResult(
              items[entry.key].entry, entry.value);
        }
        final earnedXp = 5 + session.correct * 3;
        await progress.addXp(earnedXp);
        if (!context.mounted) return;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              earnedXp: earnedXp,
              correct: session.correct,
              total: session.gradedTotal,
              passedTitle: Strings.reviewCompleted,
              homeLabel: Strings.backToReviewTab,
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
              onClose: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: KeyedSubtree(
                key: ValueKey(session.index),
                child: _buildExercise(session),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExercise(LessonSession session) {
    final ex = session.current;
    void onResult(bool isCorrect) {
      session.submitResult(isCorrect: isCorrect);
      session.next();
    }

    switch (ex.type) {
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
      case ExerciseType.info:
        // Tekrar kuyruğuna öğretici kartlar hiç girmez (bkz.
        // MistakesProvider.resolve), bu dala normalde girilmez.
        session.next();
        return const SizedBox.shrink();
    }
  }
}
