import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_colors.dart';
import '../../../core/app_data.dart';
import '../../../core/iarri_logic.dart';
import '../../auth/presentation/profile_action_button.dart';
import 'calculator_controller.dart';

class CalculatorView extends ConsumerWidget {
  const CalculatorView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora IARRI & IARM'),
        actions: [
          ProfileActionButton(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabSelector(state, notifier),
            const SizedBox(height: 16),
            if (state.activeTab == 0) _buildIarriTab(state, notifier),
            if (state.activeTab == 1) _buildIarmTab(state, notifier),
            const SizedBox(height: 24),
            _buildSectionTitle('ANÁLISIS COMBINADO IARRI × IARM'),
            const SizedBox(height: 12),
            _buildCombinedAnalysis(state),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ─── Tab selector ────────────────────────────────────────────────────────────

  Widget _buildTabSelector(CalculatorState state, CalculatorNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _buildTabButton('🧮 IARRI — Individual', 0, state.activeTab == 0,
              () => notifier.setTab(0)),
          _buildTabButton('🏙️ IARM — Territorial', 1, state.activeTab == 1,
              () => notifier.setTab(1)),
        ],
      ),
    );
  }

  Widget _buildTabButton(
      String label, int index, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Tab IARRI ───────────────────────────────────────────────────────────────

  Widget _buildIarriTab(CalculatorState state, CalculatorNotifier notifier) {
    final iarri = IARRILogic.calculateIARRI(
      av: state.iarriValues['AV']!,
      ic: state.iarriValues['IC']!,
      ed: state.iarriValues['ED']!,
      ear: state.iarriValues['EAR']!,
      imp: state.iarriValues['IMP']!,
    );
    final riskLevel = IARRILogic.getRiskLevel(iarri);
    final riskLabel = IARRILogic.getRiskLabel(riskLevel);
    final riskColor = _riskColor(riskLevel);

    // Contribuciones de cada variable al IARRI total
    final contribs = {
      'AV': 0.20 * (1 - state.iarriValues['AV']!),
      'IC': 0.25 * (1 - state.iarriValues['IC']!),
      'ED': 0.15 * (1 - state.iarriValues['ED']!),
      'EAR': 0.25 * state.iarriValues['EAR']!,
      'IMP': 0.15 * state.iarriValues['IMP']!,
    };
    final totalContrib = contribs.values.fold(0.0, (a, b) => a + b);

    return Column(
      children: [
        _buildPresetsRow(notifier),
        const SizedBox(height: 12),
        // Info hint
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
          ),
          child: Text(
            'Modificá las barras deslizantes para ajustar tu índice y obtener la mayor precisión posible.',
            style: TextStyle(
                fontSize: 12,
                color: AppColors.accent.withValues(alpha: 0.9),
                fontFamily: 'monospace'),
          ),
        ),
        const SizedBox(height: 12),
        // Sliders IARRI usando territorialVariables del dominio
        ...territorialVariables.map((v) => _buildSliderCard(
              label: v.label,
              icon: v.icon,
              desc: v.description,
              value: state.iarriValues[v.key]!,
              color: Color(v.colorValue),
              onChanged: (val) => notifier.setIarriValue(v.key, val),
              minLabel: '0.0',
              maxLabel: '1.0',
            )),
        const SizedBox(height: 16),
        // Resultado IARRI con desglose
        _buildIarriResultCard(
          iarri: iarri,
          riskLabel: riskLabel,
          riskColor: riskColor,
          contribs: contribs,
          totalContrib: totalContrib,
        ),
        const SizedBox(height: 16),
        _buildActionButtons(state, notifier),
        if (state.simulationResults != null || state.isSimulating) ...[
          const SizedBox(height: 16),
          _buildSimulationCard(state),
        ],
      ],
    );
  }

  // ─── Tab IARM ────────────────────────────────────────────────────────────────

  Widget _buildIarmTab(CalculatorState state, CalculatorNotifier notifier) {
    final iarm = IARMLogic.calculateIARM(
      st: state.iarmValues['ST']!,
      bav: state.iarmValues['BAV']!,
      den: state.iarmValues['DEN']!,
      bea: state.iarmValues['BEA']!,
    );
    final riskLabel = IARMLogic.getRiskLabel(iarm);
    final riskColor = _iarmColor(iarm);

    // Contribución de cada factor (pesos iguales = 0.25)
    final contribs = {
      for (final v in iarmVariables) v.key: state.iarmValues[v.key]! * 0.25,
    };
    final totalContrib = contribs.values.fold(0.0, (a, b) => a + b);

    // Recomendación según nivel actual
    final rec = iarmRecommendations[riskLabel];

    return Column(
      children: [
        // ── Info card fórmula ─────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'IARM = (ST + BAV + DEN + BEA) / 4',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Todos los factores son de riesgo directo: 0 = entorno protector · 1 = máximo riesgo ambiental.',
                style: TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Sliders IARM usando iarmVariables del dominio ─────────────────
        ...iarmVariables.map((v) => _buildSliderCard(
              label: v.label,
              icon: v.icon,
              desc: v.description,
              value: state.iarmValues[v.key]!,
              color: Color(v.colorValue),
              onChanged: (val) => notifier.setIarmValue(v.key, val),
              minLabel: 'Sin riesgo',
              maxLabel: 'Máx. riesgo',
            )),
        const SizedBox(height: 16),

        // ── Resultado IARM con desglose de factores ───────────────────────
        _buildIarmResultCard(
          iarm: iarm,
          riskLabel: riskLabel,
          riskColor: riskColor,
          contribs: contribs,
          totalContrib: totalContrib,
        ),

        // ── Panel de recomendaciones reactivo al nivel ────────────────────
        if (rec != null) ...[
          const SizedBox(height: 16),
          _buildIarmRecommendationPanel(rec, riskColor),
        ],

        const SizedBox(height: 8),
      ],
    );
  }

  // ─── Slider card genérico ────────────────────────────────────────────────────

  Widget _buildSliderCard({
    required String label,
    required String icon,
    required String desc,
    required double value,
    required Color color,
    required ValueChanged<double> onChanged,
    required String minLabel,
    required String maxLabel,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(icon, style: const TextStyle(fontSize: 15)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(desc,
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.muted)),
                  ],
                ),
              ),
              Text(
                value.toStringAsFixed(2),
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: color),
              ),
            ],
          ),
          Slider(
            value: value,
            onChanged: onChanged,
            activeColor: color,
            inactiveColor: AppColors.border,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(minLabel,
                    style: const TextStyle(
                        fontSize: 9, color: AppColors.muted)),
                const Text('0.5',
                    style:
                        TextStyle(fontSize: 9, color: AppColors.muted)),
                Text(maxLabel,
                    style: TextStyle(fontSize: 9, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Resultado IARRI con desglose ────────────────────────────────────────────

  Widget _buildIarriResultCard({
    required double iarri,
    required String riskLabel,
    required Color riskColor,
    required Map<String, double> contribs,
    required double totalContrib,
  }) {
    const maxContrib = 0.25; // peso máximo de cualquier variable

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE0F2FE), Color(0xFFEDE9FE)],
        ),
      ),
      child: Column(
        children: [
          // KPIs principales
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('IARRI Calculado',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.muted)),
                  Text(
                    iarri.toStringAsFixed(4),
                    style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: riskColor),
                  ),
                  Text(
                    'Prob. RI: ${(IARRILogic.calculateProbRI(iarri) * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: riskColor),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Nivel de Riesgo',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.muted)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: riskColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '● $riskLabel',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.border),
          // Desglose de contribuciones
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Desglose de Contribuciones',
                style:
                    TextStyle(fontSize: 11, color: AppColors.muted)),
          ),
          const SizedBox(height: 8),
          ...contribs.entries.map((e) {
            final varData = territorialVariables
                .firstWhere((v) => v.key == e.key);
            final color = Color(varData.colorValue);
            final pct = totalContrib > 0
                ? e.value / totalContrib * 100
                : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Text(e.key,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.muted,
                            fontFamily: 'monospace')),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (e.value / maxContrib).clamp(0.0, 1.0),
                        backgroundColor: AppColors.border,
                        color: color,
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 40,
                    child: Text(
                      e.value.toStringAsFixed(3),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontFamily: 'monospace'),
                    ),
                  ),
                  SizedBox(
                    width: 34,
                    child: Text(
                      '${pct.toStringAsFixed(1)}%',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 9, color: AppColors.muted),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Resultado IARM con desglose de factores ─────────────────────────────────

  Widget _buildIarmResultCard({
    required double iarm,
    required String riskLabel,
    required Color riskColor,
    required Map<String, double> contribs,
    required double totalContrib,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFEF3C7), Color(0xFFFCE7F3)],
        ),
      ),
      child: Column(
        children: [
          // KPIs principales
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('IARM Calculado',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.muted)),
                  Text(
                    iarm.toStringAsFixed(4),
                    style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: riskColor),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Clasificación',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.muted)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: riskColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '● $riskLabel',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.border),
          // Desglose de factores
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Desglose de Factores',
                style:
                    TextStyle(fontSize: 11, color: AppColors.muted)),
          ),
          const SizedBox(height: 8),
          ...contribs.entries.map((e) {
            final varData =
                iarmVariables.firstWhere((v) => v.key == e.key);
            final color = Color(varData.colorValue);
            final rawVal = e.value / 0.25; // valor original [0,1]
            final pct = totalContrib > 0
                ? rawVal / (totalContrib / 0.25 * 4) * 100
                : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Text(e.key,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.muted,
                            fontFamily: 'monospace')),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: rawVal.clamp(0.0, 1.0),
                        backgroundColor: AppColors.border,
                        color: color,
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 40,
                    child: Text(
                      e.value.toStringAsFixed(3),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontFamily: 'monospace'),
                    ),
                  ),
                  SizedBox(
                    width: 34,
                    child: Text(
                      '${pct.toStringAsFixed(1)}%',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 9, color: AppColors.muted),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Panel de recomendaciones IARM reactivo ───────────────────────────────────

  Widget _buildIarmRecommendationPanel(
      IarmRecommendation rec, Color riskColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: riskColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: riskColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(rec.icon,
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  rec.title,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: riskColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...rec.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•',
                      style: TextStyle(
                          fontSize: 13,
                          color: riskColor,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(item,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.text)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Botones de acción (IARRI) ────────────────────────────────────────────────

  Widget _buildActionButtons(
      CalculatorState state, CalculatorNotifier notifier) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: state.isSaving ? null : notifier.saveResult,
            icon: state.isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save_outlined, size: 18),
            label:
                Text(state.isSaving ? 'Guardando...' : 'Guardar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed:
                state.isSimulating ? null : notifier.runSimulation,
            icon: state.isSimulating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent3))
                : const Icon(Icons.bolt_outlined, size: 18),
            label: const Text('Simular'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent3,
              side: const BorderSide(color: AppColors.accent3),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Card Monte Carlo ─────────────────────────────────────────────────────────

  Widget _buildSimulationCard(CalculatorState state) {
    if (state.isSimulating) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Corriendo simulación Monte Carlo...',
                style: TextStyle(
                    fontSize: 12, color: AppColors.muted)),
          ],
        ),
      );
    }

    final results = List<double>.from(state.simulationResults!);
    final mean = results.reduce((a, b) => a + b) / results.length;
    results.sort();
    final ciLow = results[(0.025 * results.length).toInt()];
    final ciHigh = results[(0.975 * results.length).toInt()];

    // Desviación estándar
    final variance = results
            .map((r) => (r - mean) * (r - mean))
            .reduce((a, b) => a + b) /
        results.length;
    final std = variance > 0 ? variance : 0.0;

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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('📊 Monte Carlo — 1000 simulaciones',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold)),
              Text('σ = ±0.12',
                  style: TextStyle(
                      fontSize: 10, color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Perturbación aleatoria gaussiana por variable',
            style: TextStyle(fontSize: 10, color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _buildHistogramBars(results, mean),
            ),
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0.0',
                  style: TextStyle(
                      fontSize: 9, color: AppColors.muted)),
              Text('0.5',
                  style: TextStyle(
                      fontSize: 9, color: AppColors.muted)),
              Text('1.0',
                  style: TextStyle(
                      fontSize: 9, color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSimStat(
                  'Promedio', mean.toStringAsFixed(4), AppColors.accent),
              _buildSimStat('Desv. Est.',
                  std.toStringAsFixed(4), AppColors.accent3),
              _buildSimStat(
                  'IC 95%',
                  '[${ciLow.toStringAsFixed(3)}, ${ciHigh.toStringAsFixed(3)}]',
                  AppColors.mid),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildHistogramBars(List<double> results, double mean) {
    const bins = 20;
    final counts = List.filled(bins, 0);
    for (final r in results) {
      final bin = (r * bins).floor().clamp(0, bins - 1);
      counts[bin]++;
    }
    final maxCount = counts.reduce((a, b) => a > b ? a : b);

    return List.generate(bins, (i) {
      final h = (counts[i] / maxCount * 60).clamp(2.0, 60.0);
      final x = i / bins;
      final color = x < 0.33
          ? AppColors.low
          : (x < 0.66 ? AppColors.mid : AppColors.high);
      final isMean = (x - mean).abs() < 0.05;

      return Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 1),
          height: h,
          decoration: BoxDecoration(
            color: isMean
                ? AppColors.accent
                : color.withValues(alpha: 0.7),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(2)),
          ),
        ),
      );
    });
  }

  Widget _buildSimStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppColors.muted)),
        Text(value,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'monospace')),
      ],
    );
  }

  // ─── Presets de municipios ───────────────────────────────────────────────────

  Widget _buildPresetsRow(CalculatorNotifier notifier) {
    final presets = [
      {'name': 'San Andrés', 'idx': 0},
      {'name': 'San Pablo', 'idx': 1},
      {'name': 'Cuautlancingo', 'idx': 2},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: presets.map((p) {
          final m = municipios[p['idx'] as int];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(p['name'] as String),
              onPressed: () => notifier.setPreset({
                'AV': m.av,
                'IC': m.ic,
                'ED': m.ed,
                'EAR': m.ear,
                'IMP': m.imp,
              }),
              backgroundColor: AppColors.surface,
              labelStyle: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Análisis combinado IARRI × IARM ─────────────────────────────────────────

  Widget _buildCombinedAnalysis(CalculatorState state) {
    final iarri = IARRILogic.calculateIARRI(
      av: state.iarriValues['AV']!,
      ic: state.iarriValues['IC']!,
      ed: state.iarriValues['ED']!,
      ear: state.iarriValues['EAR']!,
      imp: state.iarriValues['IMP']!,
    );
    final iarm = IARMLogic.calculateIARM(
      st: state.iarmValues['ST']!,
      bav: state.iarmValues['BAV']!,
      den: state.iarmValues['DEN']!,
      bea: state.iarmValues['BEA']!,
    );

    final iarriLabel =
        IARRILogic.getRiskLabel(IARRILogic.getRiskLevel(iarri));
    final iarmLabel = IARMLogic.getRiskLabel(iarm);
    final iarriColor = _riskColor(IARRILogic.getRiskLevel(iarri));
    final iarmColor = _iarmColor(iarm);
    final narrative = CombinedNarrative.get(iarriLabel, iarmLabel);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: narrative.color.withValues(alpha: 0.4), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado narrativo
          Row(
            children: [
              Text(narrative.icon,
                  style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  narrative.title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: narrative.color),
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.border),

          // KPIs lado a lado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCombinedMiniCard(
                  'IARRI', iarri, iarriLabel, iarriColor),
              const Text('✖',
                  style: TextStyle(
                      fontSize: 18, color: AppColors.muted)),
              _buildCombinedMiniCard(
                  'IARM', iarm, iarmLabel, iarmColor),
            ],
          ),
          const SizedBox(height: 16),

          // Mensaje
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: narrative.color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: narrative.color.withValues(alpha: 0.2)),
            ),
            child: Text(narrative.message,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.text)),
          ),
          const SizedBox(height: 8),

          // Acción
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡',
                    style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(narrative.action,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.text)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedMiniCard(
      String title, double val, String label, Color color) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 10, color: AppColors.muted)),
        Text(
          val.toStringAsFixed(3),
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '● $label',
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: color),
          ),
        ),
      ],
    );
  }

  // ─── Helpers de sección y colores ────────────────────────────────────────────

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
}
