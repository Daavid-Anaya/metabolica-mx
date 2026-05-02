import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/gamification_data.dart';
import '../../profile/data/profile_repository.dart';
import '../../auth/presentation/auth_controller.dart';

class GamificationState {
  final int xp;
  final Map<String, bool> completedChallenges;
  final Map<String, List<bool>> challengeProgress;
  final Map<String, bool> unlockedBadges;
  final bool iarriGuardado;
  final int microcursosCompletados;
  final bool isLoading;

  GamificationState({
    required this.xp,
    required this.completedChallenges,
    required this.challengeProgress,
    required this.unlockedBadges,
    this.iarriGuardado = false,
    this.microcursosCompletados = 0,
    this.isLoading = false,
  });

  factory GamificationState.initial() {
    return GamificationState(
      xp: 0,
      completedChallenges: {},
      challengeProgress: {
        for (var c in weeklyChallenges) c.id: List.filled(c.steps.length, false),
      },
      unlockedBadges: {},
    );
  }

  GamificationState copyWith({
    int? xp,
    Map<String, bool>? completedChallenges,
    Map<String, List<bool>>? challengeProgress,
    Map<String, bool>? unlockedBadges,
    bool? iarriGuardado,
    int? microcursosCompletados,
    bool? isLoading,
  }) {
    return GamificationState(
      xp: xp ?? this.xp,
      completedChallenges: completedChallenges ?? this.completedChallenges,
      challengeProgress: challengeProgress ?? this.challengeProgress,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      iarriGuardado: iarriGuardado ?? this.iarriGuardado,
      microcursosCompletados: microcursosCompletados ?? this.microcursosCompletados,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class GamificationNotifier extends StateNotifier<GamificationState> {
  final ProfileRepository _repository;
  final Ref _ref;

  GamificationNotifier(this._repository, this._ref) : super(GamificationState.initial()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _ref.read(authProvider).user;
    if (user == null) return;

    state = state.copyWith(isLoading: true);
    final profile = await _repository.getProfile(user.id);
    if (profile != null) {
      state = state.copyWith(
        xp: profile.xp,
        completedChallenges: profile.completedChallenges,
        unlockedBadges: profile.unlockedBadges,
        microcursosCompletados: profile.microcursosCompletados,
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _syncWithSupabase() async {
    final user = _ref.read(authProvider).user;
    if (user == null) return;

    final profile = UserProfile(
      id: user.id,
      displayName: user.userMetadata?['display_name'] ?? 'Usuario',
      municipality: user.userMetadata?['municipality'] ?? '',
      xp: state.xp,
      completedChallenges: state.completedChallenges,
      unlockedBadges: state.unlockedBadges,
      microcursosCompletados: state.microcursosCompletados,
    );

    await _repository.updateProfile(profile);
  }

  void toggleStep(String challengeId, int stepIndex) async {
    final challenge = weeklyChallenges.firstWhere((c) => c.id == challengeId);
    final progress = List<bool>.from(state.challengeProgress[challengeId]!);
    
    progress[stepIndex] = !progress[stepIndex];
    
    final newChallengeProgress = Map<String, List<bool>>.from(state.challengeProgress);
    newChallengeProgress[challengeId] = progress;
    
    int completedCount = progress.where((done) => done).length;
    bool isCompleted = completedCount >= challenge.meta;
    
    final newCompletedChallenges = Map<String, bool>.from(state.completedChallenges);
    int xpGain = 0;
    
    if (isCompleted && !(state.completedChallenges[challengeId] ?? false)) {
      newCompletedChallenges[challengeId] = true;
      xpGain += challenge.xp;
    } else if (!isCompleted && (state.completedChallenges[challengeId] ?? false)) {
      newCompletedChallenges[challengeId] = false;
      xpGain -= challenge.xp;
    }

    state = state.copyWith(
      challengeProgress: newChallengeProgress,
      completedChallenges: newCompletedChallenges,
      xp: state.xp + xpGain,
    );
    
    _checkBadges();
    await _syncWithSupabase();
  }

  void setIarriGuardado(bool value) async {
    state = state.copyWith(iarriGuardado: value);
    _checkBadges();
    await _syncWithSupabase();
  }

  void setMicrocursosCompletados(int count) async {
    state = state.copyWith(microcursosCompletados: count);
    _checkBadges();
    await _syncWithSupabase();
  }

  void _checkBadges() {
    final newUnlockedBadges = Map<String, bool>.from(state.unlockedBadges);
    int xpBonusTotal = 0;

    for (var badge in gamificationBadges) {
      if (newUnlockedBadges[badge.id] ?? false) continue;

      bool conditionMet = false;
      switch (badge.conditionType) {
        case 'reto':
          conditionMet = state.completedChallenges[badge.conditionKey] ?? false;
          break;
        case 'bool':
          if (badge.conditionKey == 'iarri_guardado') {
            conditionMet = state.iarriGuardado;
          }
          break;
        case 'gte':
          if (badge.conditionKey == 'microcursos_completados') {
            conditionMet = state.microcursosCompletados >= (badge.conditionValue ?? 0);
          }
          break;
      }

      if (conditionMet) {
        newUnlockedBadges[badge.id] = true;
        xpBonusTotal += badge.xpBonus;
      }
    }

    if (xpBonusTotal > 0) {
      state = state.copyWith(
        unlockedBadges: newUnlockedBadges,
        xp: state.xp + xpBonusTotal,
      );
    }
  }
}

final profileRepositoryProvider = Provider((ref) => ProfileRepository());

final gamificationProvider = StateNotifierProvider<GamificationNotifier, GamificationState>((ref) {
  return GamificationNotifier(ref.watch(profileRepositoryProvider), ref);
});
