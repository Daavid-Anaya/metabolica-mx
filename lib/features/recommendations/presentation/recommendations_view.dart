import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_colors.dart';
import '../../../core/iarri_logic.dart';
import '../../auth/presentation/profile_action_button.dart';
import '../../calculator/presentation/calculator_controller.dart';
import '../domain/recommendations.dart';

class RecommendationsView extends ConsumerWidget {
  const RecommendationsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calcState = ref.watch(calculatorProvider);

    final iarri = IARRILogic.calculateIARRI(
      av: calcState.iarriValues['AV']!,
      ic: calcState.iarriValues['IC']!,
      ed: calcState.iarriValues['ED']!,
      ear: calcState.iarriValues['EAR']!,
      imp: calcState.iarriValues['IMP']!,
    );
    final iarm = IARMLogic.calculateIARM(
      st: calcState.iarmValues['ST']!,
      bav: calcState.iarmValues['BAV']!,
      den: calcState.iarmValues['DEN']!,
      bea: calcState.iarmValues['BEA']!,
    );

    final riskLevel = IARRILogic.getRiskLevel(iarri);
    final riskLabel = IARRILogic.getRiskLabel(riskLevel);
    final riskColor = _riskColor(riskLevel);

    final iarmLabel = IARMLogic.getRiskLabel(iarm);
    final iarmColor = _iarmColor(iarm);

    // Narrativa combinada IARRI × IARM
    final narrative = CombinedNarrative.get(riskLabel, iarmLabel);

    // Intervenciones priorizadas por variable más débil
    final prioritized = prioritizeInterventions(calcState.iarriValues);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intervención & Recomendaciones'),
        actions: [
          const ProfileActionButton(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Resumen resultado actual ──────────────────────────────────
            _buildResultSummary(iarri, riskLabel, riskColor),
            const SizedBox(height: 24),

            // ── Análisis Combinado IARRI × IARM ──────────────────────────
            _buildSectionTitle('ANÁLISIS COMBINADO'),
            const SizedBox(height: 8),
            _buildCombinedAnalysis(
              iarri: iarri,
              iarm: iarm,
              riskLabel: riskLabel,
              iarmLabel: iarmLabel,
              riskColor: riskColor,
              iarmColor: iarmColor,
              narrative: narrative,
            ),
            const SizedBox(height: 24),

            // ── Arquitectura Preventiva ───────────────────────────────────
            _buildSectionTitle('ARQUITECTURA PREVENTIVA'),
            const SizedBox(height: 4),
            const Text(
              'Recomendaciones personalizadas para transformar tu entorno',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            ...arqPreventiva.map((rec) => _buildExpandableCard(rec)),
            const SizedBox(height: 24),

            // ── Intervenciones Prioritarias ───────────────────────────────
            _buildSectionTitle('INTERVENCIONES PRIORITARIAS'),
            const SizedBox(height: 8),
            ...prioritized.asMap().entries.map(
              (entry) => _buildInterventionCard(
                entry.value,
                isPriority: entry.key == 0,
              ),
            ),
            const SizedBox(height: 24),

            // ── Simulación de Impacto ─────────────────────────────────────
            _buildSectionTitle('SIMULACIÓN ARQUITECTÓNICA'),
            const SizedBox(height: 12),
            _buildSimulationImpact(calcState.iarriValues),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ─── Helpers de color ───────────────────────────────────────────────────────

  Color _riskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return AppColors.low;
      case RiskLevel.mid:
        return AppColors.mid;
      case RiskLevel.high:
        return AppColors.high;
    }
  }

  Color _iarmColor(double iarm) {
    if (iarm < 0.33) return AppColors.low;
    if (iarm < 0.66) return AppColors.mid;
    return AppColors.high;
  }

  // ─── Sección título ─────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.muted,
        letterSpacing: 1.1,
      ),
    );
  }

  // ─── Resumen resultado actual ────────────────────────────────────────────────

  Widget _buildResultSummary(double iarri, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resultado actual',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniKpi('IARRI', iarri.toStringAsFixed(4), color),
              _buildMiniKpi('Nivel', label, color),
              _buildMiniKpi(
                'Prob. RI',
                '${(IARRILogic.calculateProbRI(iarri) * 100).toStringAsFixed(1)}%',
                color,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Valores basados en tu última configuración en la Calculadora.',
            style: TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniKpi(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.muted)),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }

  // ─── Análisis combinado IARRI × IARM ────────────────────────────────────────

  Widget _buildCombinedAnalysis({
    required double iarri,
    required double iarm,
    required String riskLabel,
    required String iarmLabel,
    required Color riskColor,
    required Color iarmColor,
    required CombinedNarrative narrative,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con ícono
          Row(
            children: [
              Text(narrative.icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Análisis Combinado IARRI × IARM',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // KPIs lado a lado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'IARRI',
                      style: TextStyle(fontSize: 10, color: AppColors.muted),
                    ),
                    Text(
                      iarri.toStringAsFixed(3),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: riskColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '● $riskLabel',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: riskColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Text(
                '✕',
                style: TextStyle(fontSize: 16, color: AppColors.muted),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'IARM',
                      style: TextStyle(fontSize: 10, color: AppColors.muted),
                    ),
                    Text(
                      iarm.toStringAsFixed(3),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: iarmColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '● $iarmLabel',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: iarmColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Título de la narrativa
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: narrative.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: narrative.color.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              narrative.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: narrative.color,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Mensaje
          Text(
            narrative.message,
            style: const TextStyle(fontSize: 12, color: AppColors.text),
          ),
          const SizedBox(height: 8),

          // Acción recomendada
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    narrative.action,
                    style: const TextStyle(fontSize: 12, color: AppColors.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Card expandible (Arquitectura Preventiva) ───────────────────────────────

  Widget _buildExpandableCard(Recommendation rec) {
    final categoryColor = _categoryColor(rec.category);
    final categoryLabel = _categoryLabel(rec.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ExpansionTile(
        shape: const Border(),
        leading: Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: rec.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(rec.icon, style: const TextStyle(fontSize: 24)),
        ),
        title: Text(
          rec.title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rec.subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.muted),
            ),
            const SizedBox(height: 4),
            // Chip de categoría
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: categoryColor,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                categoryLabel,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec.description,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 12),
                const Text(
                  '¿Cómo empezar?',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...rec.steps.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 9,
                          backgroundColor: rec.color,
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Impacto estimado
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: rec.color.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: rec.color.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Text('📊', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rec.estimatedImpact,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: rec.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Referencia OMS
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🌍', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        rec.omsRef,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Card de intervención priorizada ─────────────────────────────────────────

  Widget _buildInterventionCard(Intervention item, {required bool isPriority}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPriority
              ? item.color.withValues(alpha: 0.5)
              : AppColors.border,
          width: isPriority ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        spacing: 12,
        children: [
          // Ícono
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(item.icon, style: const TextStyle(fontSize: 22)),
          ),
          // Título + impacto + badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    if (isPriority)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'PRIORITARIA',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.impact,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: item.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Simulación de impacto ────────────────────────────────────────────────────

  Widget _buildSimulationImpact(Map<String, double> currentVars) {
    const deltas = {'AV': 0.25, 'IC': 0.25, 'ED': 0.20};
    final improvedVars = Map<String, double>.from(currentVars);
    deltas.forEach((key, value) {
      improvedVars[key] = (improvedVars[key]! + value).clamp(0.0, 1.0);
    });

    final iarriBefore = IARRILogic.calculateIARRI(
      av: currentVars['AV']!,
      ic: currentVars['IC']!,
      ed: currentVars['ED']!,
      ear: currentVars['EAR']!,
      imp: currentVars['IMP']!,
    );
    final iarriAfter = IARRILogic.calculateIARRI(
      av: improvedVars['AV']!,
      ic: improvedVars['IC']!,
      ed: improvedVars['ED']!,
      ear: improvedVars['EAR']!,
      imp: improvedVars['IMP']!,
    );

    final reduction =
        ((iarriBefore - iarriAfter) / iarriBefore * 100).toStringAsFixed(1);
    final probBefore = IARRILogic.calculateProbRI(iarriBefore);
    final probAfter = IARRILogic.calculateProbRI(iarriAfter);

    // Barras de progreso para las variables que cambian
    const visibleVars = ['AV', 'IC', 'ED'];
    final varColors = {
      'AV': AppColors.low,
      'IC': AppColors.accent,
      'ED': AppColors.accent3,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Simulación de Mejoras',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Escenario: +25% AV/IC, +20% Equipamiento',
            style: TextStyle(fontSize: 11, color: AppColors.muted),
          ),
          const SizedBox(height: 12),

          // Barras de progreso por variable
          ...visibleVars.map((key) {
            final before = currentVars[key]!;
            final after = improvedVars[key]!;
            final col = varColors[key]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                spacing: 8,
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      key,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.muted,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: after,
                        backgroundColor: AppColors.border,
                        color: col,
                        minHeight: 7,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: Text(
                      '${before.toStringAsFixed(2)}→${after.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: col,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),

          const Divider(height: 16, color: AppColors.border),

          // KPIs antes/después
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildImpactCol(
                'IARRI Antes',
                iarriBefore.toStringAsFixed(3),
                AppColors.muted,
              ),
              const Icon(Icons.arrow_forward, color: AppColors.accent, size: 16),
              _buildImpactCol(
                'IARRI Después',
                iarriAfter.toStringAsFixed(3),
                AppColors.low,
              ),
              _buildImpactCol('Reducción', '-$reduction%', AppColors.accent),
            ],
          ),
          const SizedBox(height: 12),

          // Probabilidad RI
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              'Prob. RI: ${(probBefore * 100).toStringAsFixed(0)}% → ${(probAfter * 100).toStringAsFixed(0)}%\n'
              'Potencial preventivo del diseño urbano (ENSANUT)',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.muted)),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }

  // ─── Helpers de categoría ────────────────────────────────────────────────────

  Color _categoryColor(String category) {
    switch (category) {
      case 'movimiento':
        return AppColors.accent;
      case 'diseño':
        return AppColors.accent3;
      case 'nutricion':
        return AppColors.low;
      default:
        return AppColors.muted;
    }
  }

  String _categoryLabel(String category) {
    switch (category) {
      case 'movimiento':
        return 'Movimiento';
      case 'diseño':
        return 'Diseño';
      case 'nutricion':
        return 'Nutrición';
      default:
        return category;
    }
  }
}
