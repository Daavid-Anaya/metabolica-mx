import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_colors.dart';
import '../../../core/iarri_logic.dart';
import '../../../core/app_data.dart';
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
          _buildTabButton('📊 IARRI — Individual', 0, state.activeTab == 0, () => notifier.setTab(0)),
          _buildTabButton('🏙️ IARM — Territorial', 1, state.activeTab == 1, () => notifier.setTab(1)),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index, bool isSelected, VoidCallback onTap) {
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
    final riskColor = _getRiskColor(riskLevel);

    return Column(
      children: [
        _buildPresetsRow(notifier),
        const SizedBox(height: 16),
        ...territorialVariables.map((v) => _buildSliderCard(
              v.label,
              v.icon,
              v.description,
              state.iarriValues[v.key]!,
              Color(v.colorValue),
              (val) => notifier.setIarriValue(v.key, val),
            )),
        const SizedBox(height: 16),
        _buildResultCard(
          title: 'IARRI Calculado',
          value: iarri,
          label: 'Riesgo $riskLabel',
          color: riskColor,
          subtitle: 'Prob. RI: ${(IARRILogic.calculateProbRI(iarri) * 100).toStringAsFixed(1)}%',
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

  Widget _buildActionButtons(CalculatorState state, CalculatorNotifier notifier) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: state.isSaving ? null : notifier.saveResult,
            icon: state.isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save_outlined, size: 18),
            label: Text(state.isSaving ? 'Guardando...' : 'Guardar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: state.isSimulating ? null : notifier.runSimulation,
            icon: state.isSimulating
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent3))
                : const Icon(Icons.bolt_outlined, size: 18),
            label: const Text('Simular'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent3,
              side: const BorderSide(color: AppColors.accent3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

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
            Text('Corriendo simulación Monte Carlo...', style: TextStyle(fontSize: 12, color: AppColors.muted)),
          ],
        ),
      );
    }

    final results = state.simulationResults!;
    final mean = results.reduce((a, b) => a + b) / results.length;
    results.sort();
    final ciLow = results[(0.025 * results.length).toInt()];
    final ciHigh = results[(0.975 * results.length).toInt()];

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
              Text('Simulación Monte Carlo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              Text('1000 iter.', style: TextStyle(fontSize: 10, color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _buildHistogramBars(results, mean),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSimStat('Promedio', mean.toStringAsFixed(4)),
              _buildSimStat('IC 95%', '[${ciLow.toStringAsFixed(3)}, ${ciHigh.toStringAsFixed(3)}]'),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildHistogramBars(List<double> results, double mean) {
    const bins = 20;
    final counts = List.filled(bins, 0);
    for (var r in results) {
      final bin = (r * bins).floor().clamp(0, bins - 1);
      counts[bin]++;
    }
    final maxCount = counts.reduce((a, b) => a > b ? a : b);

    return List.generate(bins, (i) {
      final h = (counts[i] / maxCount * 60).clamp(2.0, 60.0);
      final x = i / bins;
      final color = x < 0.33 ? AppColors.low : (x < 0.66 ? AppColors.mid : AppColors.high);
      final isMean = (x - mean).abs() < 0.05;

      return Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 1),
          height: h,
          decoration: BoxDecoration(
            color: isMean ? AppColors.accent : color.withValues(alpha: 0.7),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
          ),
        ),
      );
    });
  }

  Widget _buildSimStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.muted)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
      ],
    );
  }

  Widget _buildIarmTab(CalculatorState state, CalculatorNotifier notifier) {
    final iarm = IARMLogic.calculateIARM(
      st: state.iarmValues['ST']!,
      bav: state.iarmValues['BAV']!,
      den: state.iarmValues['DEN']!,
      bea: state.iarmValues['BEA']!,
    );
    final riskLabel = IARMLogic.getRiskLabel(iarm);
    final riskColor = iarm < 0.33 ? AppColors.low : (iarm < 0.66 ? AppColors.mid : AppColors.high);

    final iarmVars = [
      {'key': 'ST', 'label': 'Sedentarismo Territorial', 'icon': '🪑', 'color': 0xFFEF4444, 'desc': '% sin actividad física'},
      {'key': 'BAV', 'label': 'Baja Área Verde', 'icon': '🏜️', 'color': 0xFFF97316, 'desc': 'Déficit de m²/hab'},
      {'key': 'DEN', 'label': 'Alta Densidad', 'icon': '🏙️', 'color': 0xFFF59E0B, 'desc': 'Hab/km² normalizado'},
      {'key': 'BEA', 'label': 'Bajo Equipamiento', 'icon': '🚫', 'color': 0xFF8B5CF6, 'desc': 'Déficit instalaciones'},
    ];

    return Column(
      children: [
        const SizedBox(height: 8),
        ...iarmVars.map((v) => _buildSliderCard(
              v['label'] as String,
              v['icon'] as String,
              v['desc'] as String,
              state.iarmValues[v['key']]!,
              Color(v['color'] as int),
              (val) => notifier.setIarmValue(v['key'] as String, val),
              maxLabel: 'Máx. riesgo',
            )),
        const SizedBox(height: 16),
        _buildResultCard(
          title: 'IARM Calculado',
          value: iarm,
          label: riskLabel,
          color: riskColor,
          gradient: const [Color(0xFFFEF3C7), Color(0xFFFCE7F3)],
        ),
      ],
    );
  }

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
              labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSliderCard(
    String label,
    String icon,
    String desc,
    double value,
    Color color,
    ValueChanged<double> onChanged, {
    String maxLabel = '1.0',
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
                    Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(desc, style: const TextStyle(fontSize: 10, color: AppColors.muted)),
                  ],
                ),
              ),
              Text(
                value.toStringAsFixed(2),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color),
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
                const Text('0.0', style: TextStyle(fontSize: 9, color: AppColors.muted)),
                const Text('0.5', style: TextStyle(fontSize: 9, color: AppColors.muted)),
                Text(maxLabel, style: TextStyle(fontSize: 9, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required double value,
    required String label,
    required Color color,
    String? subtitle,
    List<Color>? gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient ?? [const Color(0xFFE0F2FE), const Color(0xFFEDE9FE)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
              Text(
                value.toStringAsFixed(3),
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color),
              ),
              if (subtitle != null)
                Text(subtitle, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Clasificación', style: TextStyle(fontSize: 11, color: AppColors.muted)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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

    final iarriLabel = IARRILogic.getRiskLabel(IARRILogic.getRiskLevel(iarri));
    final iarmLabel = IARMLogic.getRiskLabel(iarm);
    final narrative = CombinedNarrative.get(iarriLabel, iarmLabel);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: narrative.color.withValues(alpha: 0.4), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            narrative.title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: narrative.color),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCombinedMiniCard('IARRI', iarri, iarriLabel, _getRiskColor(IARRILogic.getRiskLevel(iarri))),
              const Text('✖', style: TextStyle(fontSize: 18, color: AppColors.muted)),
              _buildCombinedMiniCard('IARM', iarm, iarmLabel, iarm < 0.33 ? AppColors.low : (iarm < 0.66 ? AppColors.mid : AppColors.high)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: narrative.color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: narrative.color.withValues(alpha: 0.2)),
            ),
            child: Text(narrative.message, style: const TextStyle(fontSize: 12, color: AppColors.text)),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(narrative.action, style: const TextStyle(fontSize: 12, color: AppColors.text)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedMiniCard(String title, double val, String label, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 10, color: AppColors.muted)),
        Text(
          val.toStringAsFixed(3),
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '● $label',
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ],
    );
  }

  Color _getRiskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return AppColors.low;
      case RiskLevel.mid:
        return AppColors.mid;
      case RiskLevel.high:
        return AppColors.high;
    }
  }

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
}
