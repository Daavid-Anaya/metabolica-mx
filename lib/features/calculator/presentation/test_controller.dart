import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/test_questions.dart';

class TestState {
  final Map<int, bool?> answers;
  final bool showResults;
  final bool highlightPending;

  TestState({
    required this.answers,
    this.showResults = false,
    this.highlightPending = false,
  });

  factory TestState.initial() {
    return TestState(
      answers: {for (var i = 0; i < testQuestions.length; i++) i: null},
    );
  }

  int get answeredCount => answers.values.where((v) => v != null).length;
  int get yesCount => answers.values.where((v) => v == true).length;
  bool get allAnswered => answeredCount == testQuestions.length;

  TestState copyWith({
    Map<int, bool?>? answers,
    bool? showResults,
    bool? highlightPending,
  }) {
    return TestState(
      answers: answers ?? this.answers,
      showResults: showResults ?? this.showResults,
      highlightPending: highlightPending ?? this.highlightPending,
    );
  }
}

class TestNotifier extends StateNotifier<TestState> {
  TestNotifier() : super(TestState.initial());

  void setAnswer(int index, bool value) {
    final newAnswers = Map<int, bool?>.from(state.answers);
    newAnswers[index] = value;
    state = state.copyWith(answers: newAnswers, highlightPending: false);

    if (state.allAnswered) {
      state = state.copyWith(showResults: true);
    }
  }

  void submit() {
    if (state.allAnswered) {
      state = state.copyWith(showResults: true);
    } else {
      state = state.copyWith(highlightPending: true);
    }
  }

  void reset() {
    state = TestState.initial();
  }
}

final testProvider = StateNotifierProvider<TestNotifier, TestState>((ref) {
  return TestNotifier();
});
