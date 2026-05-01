import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_colors.dart';
import '../../../core/iarri_logic.dart';
import '../../../core/app_data.dart';
import 'home_controller.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final muni = municipios[homeState.selectedMunicipalityIndex];
    final iarri = IARRILogic.calculateIARRI(
      av: muni.av,
      ic: muni.ic,
      ed: muni.ed,
      ear: muni.ear,
      imp: muni.imp,
    );
    final riskLevel = IARRILogic.getRiskLevel(iarri);
    final riskLabel = IARRILogic.getRiskLabel(riskLevel);
    final riskColor = _getRiskColor(riskLevel);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ARQ-Metabólica MX'),
            Text(
              'IARRI-MX  ·  Puebla, México',
              style: GoogleFonts.manrope(
                fontSize: 11,
                color: AppColors.muted,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'v1.0',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMunicipalitySelector(ref, homeState.selectedMunicipalityIndex),
            const SizedBox(height: 16),
            _buildHeroCard(muni, iarri, riskLabel, riskColor),
            const SizedBox(height: 24),
            _buildSectionTitle('VARIABLES TERRITORIALES'),
            const SizedBox(height: 12),
            _buildVariablesGrid(muni),
            const SizedBox(height: 24),
            _buildSectionTitle('ANÁLISIS DE SENSIBILIDAD'),
            const SizedBox(height: 12),
            _buildSensitivityCard(muni),
            const SizedBox(height: 32),
            _buildSectionTitle('TEST RÁPIDO DE ENTORNO'),
            const SizedBox(height: 12),
            _buildQuickTestCard(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTestCard(BuildContext context) {
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
            'Responde preguntas sobre tu entorno urbano',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              context.push('/test');
            },
            icon: const Icon(Icons.assignment_outlined, size: 18),
            label: const Text('Iniciar test'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent3,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
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

  Widget _buildMunicipalitySelector(WidgetRef ref, int selectedIndex) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: municipios.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => ref.read(homeProvider.notifier).setMunicipalityIndex(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.border,
                ),
              ),
              child: Text(
                municipios[index].name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.muted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroCard(Municipality muni, double iarri, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE0F2FE), Color(0xFFEDE9FE)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MUNICIPIO ACTIVO',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.muted,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            muni.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                iarri.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: color,
                  height: 1,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'IARRI-MX',
                    style: TextStyle(fontSize: 10, color: AppColors.muted),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Riesgo $label',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSemaforo(iarri),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Prob. Resistencia a la Insulina:',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              Text(
                '${(IARRILogic.calculateProbRI(iarri) * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSemaforo(double iarri) {
    return Row(
      children: [
        _buildDot(AppColors.low, iarri <= 0.33),
        const SizedBox(width: 8),
        _buildDot(AppColors.mid, iarri > 0.33 && iarri <= 0.66),
        const SizedBox(width: 8),
        _buildDot(AppColors.high, iarri > 0.66),
        const SizedBox(width: 12),
        const Text(
          'Semáforo de Riesgo',
          style: TextStyle(fontSize: 11, color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _buildDot(Color color, bool isActive) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isActive ? 1 : 0.2),
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8)]
            : null,
      ),
    );
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

  Widget _buildVariablesGrid(Municipality muni) {
    final values = {
      'AV': muni.av,
      'IC': muni.ic,
      'ED': muni.ed,
      'EAR': muni.ear,
      'IMP': muni.imp,
    };

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.4,
      ),
      itemCount: territorialVariables.length,
      itemBuilder: (context, index) {
        final variable = territorialVariables[index];
        final val = values[variable.key] ?? 0.0;
        final color = Color(variable.colorValue);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(variable.icon, style: const TextStyle(fontSize: 16)),
                  ),
                  Text(
                    val.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                variable.key,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              Text(
                variable.label,
                style: const TextStyle(fontSize: 9, color: AppColors.muted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: val,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSensitivityCard(Municipality muni) {
    final weights = {
      'AV': IARRIWeights.av,
      'IC': IARRIWeights.ic,
      'ED': IARRIWeights.ed,
      'EAR': IARRIWeights.ear,
      'IMP': IARRIWeights.imp,
    };
    
    final values = {
      'AV': muni.av,
      'IC': muni.ic,
      'ED': muni.ed,
      'EAR': muni.ear,
      'IMP': muni.imp,
    };

    final isRisk = {'EAR', 'IMP'};

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
            'Contribución al IARRI',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          Text(
            'Aporte real de cada variable en ${muni.name}',
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          ...territorialVariables.map((v) {
            final weight = weights[v.key] ?? 0.0;
            final val = values[v.key] ?? 0.0;
            final contrib = isRisk.contains(v.key) ? weight * val : weight * (1 - val);
            final color = Color(v.colorValue);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Text(
                      v.key,
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
                        value: contrib / 0.25, // Normalized for visual scale
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 40,
                    child: Text(
                      contrib.toStringAsFixed(2),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontFamily: 'monospace',
                      ),
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
}
