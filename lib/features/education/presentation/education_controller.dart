import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/education_data.dart';

// ─── ENUM ─────────────────────────────────────────────────────────────────────

enum EducationViewState { home, microcourse, lesson, evaluation }

// ─── STATE ────────────────────────────────────────────────────────────────────

class EducationState {
  /// Mapa de progreso:
  /// - leccion_X_completada → bool
  /// - leccion_X_puntaje    → int (correctas)
  /// - mc_X_xp              → int
  /// - mc_X_evaluacion_completada → bool
  final Map<String, dynamic> progress;
  final EducationViewState view;
  final Microcourse? activeMicrocourse;
  final Lesson? activeLesson;
  final bool fromMicrocourse;

  const EducationState({
    this.progress = const {},
    this.view = EducationViewState.home,
    this.activeMicrocourse,
    this.activeLesson,
    this.fromMicrocourse = false,
  });

  EducationState copyWith({
    Map<String, dynamic>? progress,
    EducationViewState? view,
    Microcourse? activeMicrocourse,
    Lesson? activeLesson,
    bool? fromMicrocourse,
    bool clearActiveMicrocourse = false,
    bool clearActiveLesson = false,
  }) {
    return EducationState(
      progress: progress ?? this.progress,
      view: view ?? this.view,
      activeMicrocourse:
          clearActiveMicrocourse ? null : activeMicrocourse ?? this.activeMicrocourse,
      activeLesson:
          clearActiveLesson ? null : activeLesson ?? this.activeLesson,
      fromMicrocourse: fromMicrocourse ?? this.fromMicrocourse,
    );
  }
}

// ─── NOTIFIER ─────────────────────────────────────────────────────────────────

class EducationNotifier extends StateNotifier<EducationState> {
  EducationNotifier() : super(const EducationState());

  void openMicrocourse(Microcourse mc) {
    state = state.copyWith(
      view: EducationViewState.microcourse,
      activeMicrocourse: mc,
    );
  }

  void openLesson(Lesson lesson, {bool fromMicrocourse = false}) {
    state = state.copyWith(
      view: EducationViewState.lesson,
      activeLesson: lesson,
      fromMicrocourse: fromMicrocourse,
    );
  }

  void openEvaluation(Microcourse mc) {
    state = state.copyWith(
      view: EducationViewState.evaluation,
      activeMicrocourse: mc,
    );
  }

  /// Navega hacia atrás según el stack:
  /// evaluacion → microcurso
  /// leccion (desde microcurso) → microcurso
  /// leccion (individual) → home
  /// microcurso → home
  void goBack() {
    switch (state.view) {
      case EducationViewState.evaluation:
        state = state.copyWith(view: EducationViewState.microcourse);
      case EducationViewState.lesson:
        if (state.fromMicrocourse) {
          state = state.copyWith(
            view: EducationViewState.microcourse,
            clearActiveLesson: true,
          );
        } else {
          state = state.copyWith(
            view: EducationViewState.home,
            clearActiveLesson: true,
          );
        }
      case EducationViewState.microcourse:
        state = state.copyWith(
          view: EducationViewState.home,
          clearActiveMicrocourse: true,
        );
      case EducationViewState.home:
        break;
    }
  }

  /// Registra la lección como completada y guarda el puntaje.
  void completeLesson(int lessonId, int correctAnswers) {
    final updated = Map<String, dynamic>.from(state.progress);
    updated['leccion_${lessonId}_completada'] = true;
    updated['leccion_${lessonId}_puntaje'] = correctAnswers;
    state = state.copyWith(progress: updated);
  }

  /// Registra la evaluación de un microcurso como completada y guarda el XP.
  void completeEvaluation(String mcId, int xpEarned) {
    final updated = Map<String, dynamic>.from(state.progress);
    updated['mc_${mcId}_xp'] = xpEarned;
    updated['mc_${mcId}_evaluacion_completada'] = true;
    state = state.copyWith(progress: updated);
  }
}

// ─── PROVIDER ─────────────────────────────────────────────────────────────────

final educationProvider =
    StateNotifierProvider<EducationNotifier, EducationState>(
  (ref) => EducationNotifier(),
);
