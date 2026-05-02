import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  final String id;
  final String displayName;
  final String municipality;
  final int xp;
  final Map<String, bool> unlockedBadges;
  final Map<String, bool> completedChallenges;
  final int microcursosCompletados;
  final Map<String, dynamic> educationProgress;

  UserProfile({
    required this.id,
    required this.displayName,
    required this.municipality,
    this.xp = 0,
    this.unlockedBadges = const {},
    this.completedChallenges = const {},
    this.microcursosCompletados = 0,
    this.educationProgress = const {},
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      displayName: json['nombre'] ?? 'Usuario',
      municipality: json['municipio_actual'] ?? '',
      xp: json['xp'] ?? 0,
      unlockedBadges: Map<String, bool>.from(json['unlocked_badges'] ?? {}),
      completedChallenges: Map<String, bool>.from(json['completed_challenges'] ?? {}),
      microcursosCompletados: json['microcursos_completados'] ?? 0,
      educationProgress: Map<String, dynamic>.from(json['education_progress'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': displayName,
      'municipio_actual': municipality,
      'xp': xp,
      'unlocked_badges': unlockedBadges,
      'completed_challenges': completedChallenges,
      'microcursos_completados': microcursosCompletados,
      'education_progress': educationProgress,
    };
  }
}

class ProfileRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<UserProfile?> getProfile(String userId) async {
    final response = await _supabase
        .from('perfiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    
    if (response == null) return null;
    return UserProfile.fromJson(response);
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _supabase.from('perfiles').upsert(profile.toJson());
  }
}
