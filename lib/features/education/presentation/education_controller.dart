import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/education_data.dart';
import '../../profile/data/profile_repository.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../gamification/presentation/gamification_controller.dart';

// ─── ENUM ─────────────────────────────────────────────────────────────────────

enum EducationViewState { home, microcourse, lesson, evaluation }

// ─── STATE ────────────────────────────────────────────────────────────────────

class EducationState {
  final Map<String, dynamic> progress;
  final EducationViewState view;
  final Microcourse? activeMicrocourse;
  final Lesson? activeLesson;
  final bool fromMicrocourse;
  final bool isLoading;

  const EducationState({
    this.progress = const {},
    this.view = EducationViewState.home,
    this.activeMicrocourse,
    this.activeLesson,
    this.fromMicrocourse = false,
    this.isLoading = false,
  });

  EducationState copyWith({
    Map<String, dynamic>? progress,
    EducationViewState? view,
    Microcourse? activeMicrocourse,
    Lesson? activeLesson,
    bool? fromMicrocourse,
    bool? isLoading,
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
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ─── NOTIFIER ─────────────────────────────────────────────────────────────────

class EducationNotifier extends StateNotifier<EducationState> {
  final ProfileRepository _repository;
  final Ref _ref;

  EducationNotifier(this._repository, this._ref) : super(const EducationState()) {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final user = _ref.read(authProvider).user;
    if (user == null) return;

    state = state.copyWith(isLoading: true);
    final profile = await _repository.getProfile(user.id);
    if (profile != null) {
      state = state.copyWith(
        progress: profile.educationProgress,
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _syncWithSupabase() async {
    final user = _ref.read(authProvider).user;
    if (user == null) return;

    // Get current profile to preserve other fields
    final profile = await _repository.getProfile(user.id);
    if (profile == null) return;

    final updatedProfile = UserProfile(
      id: profile.id,
      displayName: profile.displayName,
      municipality: profile.municipality,
      xp: profile.xp,
      unlockedBadges: profile.unlockedBadges,
      completedChallenges: profile.completedChallenges,
      microcursosCompletados: profile.microcursosCompletados,
      educationProgress: state.progress,
    );

    await _repository.updateProfile(updatedProfile);
  }

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

  void completeLesson(int lessonId, int correctAnswers) async {
    final updated = Map<String, dynamic>.from(state.progress);
    updated['leccion_${lessonId}_completada'] = true;
    updated['leccion_${lessonId}_puntaje'] = correctAnswers;
    state = state.copyWith(progress: updated);
    await _syncWithSupabase();
  }

  void completeEvaluation(String mcId, int xpEarned) async {
    final updated = Map<String, dynamic>.from(state.progress);
    updated['mc_${mcId}_xp'] = xpEarned;
    updated['mc_${mcId}_evaluacion_completada'] = true;
    state = state.copyWith(progress: updated);
    
    // Update global XP and courses count in Gamification
    final totalCompleted = updated.entries
        .where((e) => e.key.endsWith('_evaluacion_completada') && e.value == true)
        .length;
    
    _ref.read(gamificationProvider.notifier).setMicrocursosCompletados(totalCompleted);
    
    await _syncWithSupabase();
  }
}

// ─── PROVIDER ─────────────────────────────────────────────────────────────────

final educationProvider =
    StateNotifierProvider<EducationNotifier, EducationState>(
  (ref) => EducationNotifier(ref.watch(profileRepositoryProvider), ref),
);
