import 'package:supabase_flutter/supabase_flutter.dart';

class IarriResult {
  final int? id;
  final String userId;
  final String municipio;
  final double iarri;
  final double probRi; // Keep for local use
  final Map<String, double> iarriValues; // Keep for local use
  final Map<String, double> iarmValues; // Keep for local use
  final DateTime createdAt;

  IarriResult({
    this.id,
    required this.userId,
    required this.municipio,
    required this.iarri,
    required this.probRi,
    required this.iarriValues,
    required this.iarmValues,
    required this.createdAt,
  });

  factory IarriResult.fromJson(Map<String, dynamic> json) {
    return IarriResult(
      id: json['id'],
      userId: json['usuario_id'],
      municipio: json['municipio'] ?? 'Sin especificar',
      iarri: (json['iarri_total'] as num).toDouble(),
      probRi: (json['prob_ri'] as num?)?.toDouble() ?? 0.0,
      iarriValues: Map<String, double>.from(json['iarri_values'] ?? {}),
      iarmValues: Map<String, double>.from(json['iarm_values'] ?? {}),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario_id': userId,
      'municipio': municipio,
      'iarri_total': iarri,
      'nivel_riesgo': _getRiskLevel(iarri),
      'prob_ri': probRi,
      'iarri_values': iarriValues,
      'iarm_values': iarmValues,
    };
  }

  static String _getRiskLevel(double iarri) {
    if (iarri < 0.25) return 'Bajo';
    if (iarri < 0.5) return 'Medio';
    return 'Alto';
  }
}

class ResultsRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> saveResult(IarriResult result) async {
    await _supabase.from('resultados_iarri').insert(result.toJson());
  }

  Future<List<IarriResult>> getResults(String userId) async {
    final response = await _supabase
        .from('resultados_iarri')
        .select()
        .eq('usuario_id', userId)
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => IarriResult.fromJson(json)).toList();
  }
}
