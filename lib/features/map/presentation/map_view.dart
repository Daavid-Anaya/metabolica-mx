import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../config/app_colors.dart';
import '../../../core/iarri_logic.dart';
import '../domain/map_data.dart';
import 'map_controller.dart';
import '../../auth/presentation/profile_action_button.dart';

// ---------------------------------------------------------------------------
// MapView — ConsumerWidget raíz
// ---------------------------------------------------------------------------

class MapView extends ConsumerWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mapProvider);
    final notifier = ref.read(mapProvider.notifier);
    final muniData = territorialData[state.selectedMunicipality]!;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          state.selectedNeighborhood != null
              ? 'Perfil Metabólico'
              : 'Mapa Territorial',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        actions: [
          if (state.selectedNeighborhood != null)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              color: AppColors.text,
              onPressed: notifier.clearNeighborhood,
              tooltip: 'Volver al mapa',
            ),
          const ProfileActionButton(),
        ],
      ),
      body: state.selectedNeighborhood == null
          ? _MapMunicipalOverview(data: muniData, state: state, notifier: notifier)
          : _MapNeighborhoodDetail(
              neighborhood: state.selectedNeighborhood!,
              municipalData: muniData,
              notifier: notifier,
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper top-level: risk color
// ---------------------------------------------------------------------------

Color _riskColor(double value, {bool inverse = true}) {
  final risk = inverse ? (1 - value) : value;
  if (risk < 0.33) return AppColors.low;
  if (risk < 0.66) return AppColors.mid;
  return AppColors.high;
}

Color _iarriColor(double iarri) {
  if (iarri < 0.33) return AppColors.low;
  if (iarri < 0.66) return AppColors.mid;
  return AppColors.high;
}

String _iarriEmoji(double iarri) {
  if (iarri < 0.33) return '✅';
  if (iarri < 0.66) return '🟡';
  return '🚨';
}

String _iarriLabel(double iarri) {
  if (iarri < 0.33) return 'BAJO';
  if (iarri < 0.66) return 'MODERADO';
  return 'ALTO';
}

String _formatPopulation(int pop) {
  if (pop >= 1000000) return '${(pop / 1000000).toStringAsFixed(1)}M hab';
  if (pop >= 1000) return '${(pop / 1000).toStringAsFixed(0)}k hab';
  return '$pop hab';
}

Color _hexColor(String hex) {
  final clean = hex.replaceAll('#', '');
  return Color(int.parse('FF$clean', radix: 16));
}

// ---------------------------------------------------------------------------
// Section title widget (reutilizable)
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
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

// ---------------------------------------------------------------------------
// Progress bar helper
// ---------------------------------------------------------------------------

class _ProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;

  const _ProgressBar({
    required this.value,
    required this.color,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        backgroundColor: AppColors.border,
        valueColor: AlwaysStoppedAnimation<Color>(color),
        minHeight: height,
      ),
    );
  }
}

// ===========================================================================
// MUNICIPAL OVERVIEW
// ===========================================================================

class _MapMunicipalOverview extends StatelessWidget {
  final MunicipalityTerritorialData data;
  final MapState state;
  final MapNotifier notifier;

  const _MapMunicipalOverview({
    required this.data,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final iarri = IARRILogic.calculateIARRI(
      av: data.av,
      ic: data.ic,
      ed: data.ed,
      ear: data.ear,
      imp: data.imp,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Municipality Header
          _buildMunicipalHeader(iarri),
          const SizedBox(height: 16),

          // 2. Interactive Map
          _buildInteractiveMap(),
          const SizedBox(height: 8),

          // 3. Legend
          _buildLegend(),
          const SizedBox(height: 20),

          // 4. Quick Comparison
          const _SectionTitle('COMPARATIVA RÁPIDA'),
          const SizedBox(height: 10),
          _buildQuickComparison(),
          const SizedBox(height: 20),

          // 5. Territorial Variables (6 cards)
          const _SectionTitle('VARIABLES TERRITORIALES'),
          const SizedBox(height: 10),
          _buildTerritorialVariables(),
          const SizedBox(height: 20),

          // 6. Neighborhoods
          const _SectionTitle('TU COLONIA — PERFIL METABÓLICO AMBIENTAL'),
          const SizedBox(height: 6),
          const Text(
            'Toca una colonia para ver su análisis detallado',
            style: TextStyle(fontSize: 11, color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          ...data.neighborhoods.map((n) => _buildNeighborhoodCard(n)),
          const SizedBox(height: 20),

          // 7. Municipal Ranking
          const _SectionTitle('RANKING MUNICIPAL — IARRI'),
          const SizedBox(height: 10),
          _buildMunicipalRanking(),
          const SizedBox(height: 20),

          // 8. Disclaimer
          _buildDisclaimer(),
        ],
      ),
    );
  }

  // ---- 1. Municipality Header ----

  Widget _buildMunicipalHeader(double iarri) {
    final color = _iarriColor(iarri);
    final label = _iarriLabel(iarri);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.text.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label monospace
          const Text(
            'ANÁLISIS TERRITORIAL — INEGI / CONAPO / DENUE',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),

          // Municipality selector chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: territorialData.keys.map((name) {
                final isSelected = state.selectedMunicipality == name;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => notifier.setMunicipality(name),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.bg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.muted,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Municipality name + population
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatPopulation(data.population),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    iarri.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: color,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: color.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      'IARRI $label',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---- 2. Interactive Map ----

  Widget _buildInteractiveMap() {
    // Center between all municipalities
    const mapCenter = LatLng(19.057, -98.272);

    final allMarkers = <Marker>[];
    final allCircles = <CircleMarker>[];
    final allPoiMarkers = <Marker>[];

    for (final entry in territorialData.entries) {
      final mData = entry.value;
      final mName = entry.key;
      final isActive = mName == state.selectedMunicipality;

      final mIarri = IARRILogic.calculateIARRI(
        av: mData.av,
        ic: mData.ic,
        ed: mData.ed,
        ear: mData.ear,
        imp: mData.imp,
      );
      final mColor = _iarriColor(mIarri);
      final mPoint = LatLng(mData.lat, mData.lon);

      // Risk circle — pixel radius scaled to IARRI (approximate visual)
      allCircles.add(
        CircleMarker(
          point: mPoint,
          radius: 700 + mIarri * 1800,
          useRadiusInMeter: true,
          color: mColor.withValues(alpha: 0.10),
          borderColor: mColor.withValues(alpha: 0.35),
          borderStrokeWidth: 1.5,
        ),
      );

      // Municipality marker pill
      allMarkers.add(
        Marker(
          point: mPoint,
          width: 130,
          height: 48,
          child: GestureDetector(
            onTap: () => notifier.setMunicipality(mName),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: mColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isActive ? Colors.white : mColor,
                  width: isActive ? 2.5 : 0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: mColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    mName.split(' ').take(2).join(' '),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'IARRI ${mIarri.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // POI markers for active municipality only
      if (isActive) {
        for (final poi in mData.pois) {
          final cfg = poiTypeConfig[poi.type]!;
          final poiColor = _hexColor(cfg.color);
          allPoiMarkers.add(
            Marker(
              point: LatLng(poi.lat, poi.lon),
              width: 32,
              height: 32,
              child: Tooltip(
                message: '${poi.title}\n${poi.description}',
                child: Container(
                  decoration: BoxDecoration(
                    color: poiColor.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: poiColor.withValues(alpha: 0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      cfg.emoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.text.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 280,
          child: Stack(
            children: [
              FlutterMap(
                options: const MapOptions(
                  initialCenter: mapCenter,
                  initialZoom: 11.8,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.metabolica.app',
                  ),
                  CircleLayer(circles: allCircles),
                  MarkerLayer(markers: allMarkers),
                  MarkerLayer(markers: allPoiMarkers),
                ],
              ),
              // Footer
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  color: Colors.white.withValues(alpha: 0.85),
                  child: const Text(
                    'OpenStreetMap · toca un marcador para ver datos',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.muted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- 3. Legend ----

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: risk dots
          Row(
            children: [
              _legendDot(AppColors.low, 'Riesgo bajo'),
              const SizedBox(width: 14),
              _legendDot(AppColors.mid, 'Moderado'),
              const SizedBox(width: 14),
              _legendDot(AppColors.high, 'Alto'),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: POI emojis
          Row(
            children: poiTypeConfig.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(e.value.emoji, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      e.key.name[0].toUpperCase() + e.key.name.substring(1),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          const Text(
            'Fuente: OSM · INEGI 2020',
            style: TextStyle(fontSize: 9, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.muted),
        ),
      ],
    );
  }

  // ---- 4. Quick Comparison ----

  Widget _buildQuickComparison() {
    final sorted = territorialData.entries.toList();
    return Column(
      children: sorted.map((entry) {
        final mData = entry.value;
        final mIarri = IARRILogic.calculateIARRI(
          av: mData.av,
          ic: mData.ic,
          ed: mData.ed,
          ear: mData.ear,
          imp: mData.imp,
        );
        final color = _iarriColor(mIarri);
        final isActive = entry.key == state.selectedMunicipality;

        return GestureDetector(
          onTap: () => notifier.setMunicipality(entry.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isActive
                  ? color.withValues(alpha: 0.08)
                  : AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive ? color.withValues(alpha: 0.5) : AppColors.border,
                width: isActive ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mData.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 4 mini progress bars
                      _miniBar('AV', mData.av, true),
                      const SizedBox(height: 4),
                      _miniBar('IC', mData.ic, true),
                      const SizedBox(height: 4),
                      _miniBar('ED', mData.ed, true),
                      const SizedBox(height: 4),
                      _miniBar('EAR', mData.ear, false),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      mIarri.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: color,
                        height: 1,
                      ),
                    ),
                    Text(
                      _iarriLabel(mIarri),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _miniBar(String label, double value, bool inverse) {
    final color = _riskColor(value, inverse: inverse);
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
        ),
        Expanded(
          child: _ProgressBar(value: value, color: color, height: 4),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 28,
          child: Text(
            value.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  // ---- 5. Territorial Variables (6 cards) ----

  Widget _buildTerritorialVariables() {
    return Column(
      children: [
        _variableCard(
          emoji: '🌳',
          title: 'Áreas Verdes',
          subtitle: 'OMS recomienda ≥ 9 m²/hab',
          value: '${data.greenAreasM2.toStringAsFixed(1)} m²/hab',
          progress: data.av,
          inverse: true,
          leftLabel: '0 m²',
          rightLabel: '${data.omsStandard.toStringAsFixed(0)} m²',
        ),
        _variableCard(
          emoji: '🏘️',
          title: 'Densidad Poblacional',
          subtitle: 'hab/km²',
          value: '${data.density} hab/km²',
          progress: data.density / data.densityMax,
          inverse: false,
          leftLabel: 'Baja',
          rightLabel: 'Alta',
        ),
        _variableCard(
          emoji: '📉',
          title: 'Índice de Marginación',
          subtitle: 'CONAPO 2020 · 0 = sin marginación',
          value: data.marginacion.toStringAsFixed(2),
          progress: data.imp,
          inverse: false,
          leftLabel: '0.0',
          rightLabel: '1.0',
        ),
        _variableCard(
          emoji: '⚽',
          title: 'Equipamiento Deportivo',
          subtitle: 'por 10k hab · ideal ≥ ${data.sportsEquipIdeal.toStringAsFixed(0)}',
          value: '${data.sportsEquip.toStringAsFixed(1)}/10k',
          progress: data.ed,
          inverse: true,
          leftLabel: '0',
          rightLabel: data.sportsEquipIdeal.toStringAsFixed(0),
        ),
        _variableCard(
          emoji: '🚶',
          title: 'Movilidad Peatonal',
          subtitle: 'Índice de caminabilidad (%)',
          value: '${(data.mobility * 100).toStringAsFixed(0)}%',
          progress: data.ic,
          inverse: true,
          leftLabel: '0%',
          rightLabel: '100%',
        ),
        _variableCard(
          emoji: '🍟',
          title: 'Entorno Alimentario Riesgoso',
          subtitle: 'Proporción de establecimientos ultra.',
          value: '${(data.ultraprocessed * 100).toStringAsFixed(0)}%',
          progress: data.ear,
          inverse: false,
          leftLabel: '0%',
          rightLabel: '100%',
        ),
      ],
    );
  }

  Widget _variableCard({
    required String emoji,
    required String title,
    required String subtitle,
    required String value,
    required double progress,
    required bool inverse,
    required String leftLabel,
    required String rightLabel,
  }) {
    final color = _riskColor(progress, inverse: inverse);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.text.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ProgressBar(value: progress, color: color, height: 7),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                leftLabel,
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.muted,
                ),
              ),
              Text(
                rightLabel,
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---- 6. Neighborhood cards ----

  Widget _buildNeighborhoodCard(Neighborhood n) {
    final color = _iarriColor(n.iarri);
    final prob = IARRILogic.calculateProbRI(n.iarri);

    return GestureDetector(
      onTap: () => notifier.setNeighborhood(n),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.text.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _iarriEmoji(n.iarri),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        '${_formatPopulation(n.population)} · ${_iarriLabel(n.iarri)}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      n.iarri.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: color,
                        height: 1,
                      ),
                    ),
                    Text(
                      '${(prob * 100).toStringAsFixed(0)}% RI',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 5 chips: AV, IC, ED, EAR, IMP
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _chip('AV', n.av, true),
                _chip('IC', n.ic, true),
                _chip('ED', n.ed, true),
                _chip('EAR', n.ear, false),
                _chip('IMP', n.imp, false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, double value, bool inverse) {
    final color = _riskColor(value, inverse: inverse);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        '$label ${value.toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  // ---- 7. Municipal Ranking ----

  Widget _buildMunicipalRanking() {
    // Sort by IARRI ascending (lower = better)
    final entries = territorialData.entries.toList();
    entries.sort((a, b) {
      final aIarri = IARRILogic.calculateIARRI(
        av: a.value.av,
        ic: a.value.ic,
        ed: a.value.ed,
        ear: a.value.ear,
        imp: a.value.imp,
      );
      final bIarri = IARRILogic.calculateIARRI(
        av: b.value.av,
        ic: b.value.ic,
        ed: b.value.ed,
        ear: b.value.ear,
        imp: b.value.imp,
      );
      return aIarri.compareTo(bIarri);
    });

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: entries.asMap().entries.map((mapEntry) {
          final rank = mapEntry.key + 1;
          final entry = mapEntry.value;
          final mData = entry.value;
          final mIarri = IARRILogic.calculateIARRI(
            av: mData.av,
            ic: mData.ic,
            ed: mData.ed,
            ear: mData.ear,
            imp: mData.imp,
          );
          final color = _iarriColor(mIarri);
          final prob = IARRILogic.calculateProbRI(mIarri);
          final isLast = rank == entries.length;

          return GestureDetector(
            onTap: () => notifier.setMunicipality(entry.key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : const Border(
                        bottom: BorderSide(color: AppColors.border),
                      ),
              ),
              child: Row(
                children: [
                  // Rank number
                  SizedBox(
                    width: 24,
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: rank == 1 ? AppColors.low : AppColors.muted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Name
                  SizedBox(
                    width: 130,
                    child: Text(
                      mData.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Progress bar
                  Expanded(
                    child: _ProgressBar(value: mIarri, color: color, height: 5),
                  ),
                  const SizedBox(width: 8),
                  // IARRI + Prob
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        mIarri.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                      ),
                      Text(
                        '${(prob * 100).toStringAsFixed(0)}% RI',
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ---- 8. Disclaimer ----

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.accent),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'El IARRI es una estimación poblacional basada en variables territoriales '
              '(INEGI / CONAPO / DENUE). No constituye diagnóstico médico individual. '
              'Consulta a tu médico para evaluación clínica personalizada.',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// NEIGHBORHOOD DETAIL
// ===========================================================================

class _MapNeighborhoodDetail extends StatelessWidget {
  final Neighborhood neighborhood;
  final MunicipalityTerritorialData municipalData;
  final MapNotifier notifier;

  const _MapNeighborhoodDetail({
    required this.neighborhood,
    required this.municipalData,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final n = neighborhood;
    final diagnosis = diagnoseNeighborhood(n);
    final color = _iarriColor(n.iarri);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button header
          _buildBackHeader(context),
          const SizedBox(height: 16),

          // 1. Hero Card
          _buildHeroCard(n, diagnosis, color),
          const SizedBox(height: 20),

          // 2. Variable Detail Cards (5)
          const _SectionTitle('VARIABLES — ANÁLISIS DETALLADO'),
          const SizedBox(height: 10),
          _buildVariableDetail(n),
          const SizedBox(height: 20),

          // 3. Alerts
          if (diagnosis.alerts.isNotEmpty) ...[
            const _SectionTitle('ALERTAS METABÓLICAS'),
            const SizedBox(height: 10),
            _buildAlerts(diagnosis.alerts),
            const SizedBox(height: 20),
          ],

          // 4. Strengths
          if (diagnosis.strengths.isNotEmpty) ...[
            const _SectionTitle('FACTORES PROTECTORES'),
            const SizedBox(height: 10),
            _buildStrengths(diagnosis.strengths),
            const SizedBox(height: 20),
          ],

          // 5. Comparison Table
          const _SectionTitle('COLONIA VS MUNICIPIO'),
          const SizedBox(height: 10),
          _buildComparisonTable(n),
          const SizedBox(height: 20),

          // 6. Recommendations
          if (diagnosis.recommendations.isNotEmpty) ...[
            const _SectionTitle('RECOMENDACIONES TERRITORIALES'),
            const SizedBox(height: 10),
            _buildRecommendations(diagnosis.recommendations),
            const SizedBox(height: 20),
          ],

          // 7. Disclaimer
          _buildDisclaimer(),
        ],
      ),
    );
  }

  // ---- Back header ----

  Widget _buildBackHeader(BuildContext context) {
    return GestureDetector(
      onTap: notifier.clearNeighborhood,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 14,
              color: AppColors.text,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Perfil Metabólico',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  neighborhood.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- 1. Hero Card ----

  Widget _buildHeroCard(
    Neighborhood n,
    NeighborhoodDiagnosis diagnosis,
    Color color,
  ) {
    final prob = diagnosis.probRI;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.85), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          const Text(
            'PERFIL METABÓLICO AMBIENTAL',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),

          // Name + location
          Text(
            n.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          Text(
            '${municipalData.name} · Puebla, México',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 18),

          // Stats row
          Row(
            children: [
              _heroStat(
                label: 'IARRI',
                value: n.iarri.toStringAsFixed(2),
                fontSize: 52,
              ),
              Container(
                width: 1,
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 18),
                color: Colors.white30,
              ),
              _heroStat(
                label: 'Prob. RI',
                value: '${(prob * 100).toStringAsFixed(0)}%',
                fontSize: 24,
              ),
              const Spacer(),
              // Level badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white30),
                ),
                child: Text(
                  _iarriLabel(n.iarri),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Population
          Row(
            children: [
              const Icon(Icons.people_outline, color: Colors.white60, size: 14),
              const SizedBox(width: 4),
              Text(
                _formatPopulation(n.population),
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Diagnosis title + subtitle
          Text(
            diagnosis.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            diagnosis.subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _heroStat({
    required String label,
    required String value,
    double fontSize = 24,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ---- 2. Variable Detail Cards ----

  Widget _buildVariableDetail(Neighborhood n) {
    return Column(
      children: [
        _detailCard(
          emoji: '🌳',
          title: 'Áreas Verdes',
          subtitle: 'vs OMS 9 m²/hab',
          value: '${n.greenAreasM2.toStringAsFixed(1)} m²/hab',
          progress: n.av,
          inverse: true,
          muniProgress: municipalData.av,
          badge: _badge(n.av, true),
        ),
        _detailCard(
          emoji: '🏘️',
          title: 'Densidad Poblacional',
          subtitle: 'hab/km²',
          value: '${n.density} hab/km²',
          progress: n.density / municipalData.densityMax.toDouble(),
          inverse: false,
          muniProgress: municipalData.density / municipalData.densityMax.toDouble(),
          badge: _badgeRaw(n.density, municipalData.densityMax.toDouble(), false),
        ),
        _detailCard(
          emoji: '📉',
          title: 'Marginación',
          subtitle: 'Grado: ${n.marginacionGrade}',
          value: n.marginacion.toStringAsFixed(2),
          progress: n.imp,
          inverse: false,
          muniProgress: municipalData.imp,
          badge: _badge(n.imp, false),
        ),
        _detailCard(
          emoji: '⚽',
          title: 'Equipamiento Deportivo',
          subtitle: 'por 10k hab',
          value: '${n.sportsEquip.toStringAsFixed(1)}/10k',
          progress: n.ed,
          inverse: true,
          muniProgress: municipalData.ed,
          badge: _badge(n.ed, true),
        ),
        _detailCard(
          emoji: '🚶',
          title: 'Movilidad Peatonal',
          subtitle: 'Índice de caminabilidad',
          value: '${(n.mobility * 100).toStringAsFixed(0)}%',
          progress: n.ic,
          inverse: true,
          muniProgress: municipalData.ic,
          badge: _badge(n.ic, true),
        ),
      ],
    );
  }

  Widget _badge(double value, bool inverse) {
    final color = _riskColor(value, inverse: inverse);
    final label = color == AppColors.low
        ? 'OK'
        : (color == AppColors.mid ? 'Atención' : 'Crítico');
    return _statusBadge(label, color);
  }

  Widget _badgeRaw(num rawValue, double max, bool inverse) {
    final pct = (rawValue / max).clamp(0.0, 1.0);
    return _badge(pct, inverse);
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _detailCard({
    required String emoji,
    required String title,
    required String subtitle,
    required String value,
    required double progress,
    required bool inverse,
    required double muniProgress,
    required Widget badge,
  }) {
    final color = _riskColor(progress, inverse: inverse);
    final muniColor = _riskColor(muniProgress, inverse: inverse);
    final delta = progress - muniProgress;
    final deltaStr =
        '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(2)} vs municipio';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.text.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                  badge,
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Colonia progress
          _ProgressBar(value: progress, color: color, height: 6),
          const SizedBox(height: 5),
          // Municipality comparison bar (lighter)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: muniProgress.clamp(0.0, 1.0),
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    muniColor.withValues(alpha: 0.4),
                  ),
                  minHeight: 4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            deltaStr,
            style: TextStyle(
              fontSize: 9,
              color: delta >= 0
                  ? (inverse ? AppColors.low : AppColors.high)
                  : (inverse ? AppColors.high : AppColors.low),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ---- 3. Alerts ----

  Widget _buildAlerts(List<NeighborhoodAlert> alerts) {
    return Column(
      children: alerts.map((alert) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: alert.color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: alert.color.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: alert.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Text(
                    alert.emoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.text,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: alert.color,
                      ),
                    ),
                    Text(
                      alert.impact,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ---- 4. Strengths ----

  Widget _buildStrengths(List<NeighborhoodAlert> strengths) {
    return Column(
      children: strengths.map((s) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.low.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.low.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.low.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_outline,
                    color: AppColors.low,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.text,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.low,
                      ),
                    ),
                    Text(
                      s.impact,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ---- 5. Comparison Table ----

  Widget _buildComparisonTable(Neighborhood n) {
    final rows = [
      _CompRow('AV', n.av, municipalData.av, true, 'Áreas Verdes'),
      _CompRow('IC', n.ic, municipalData.ic, true, 'Caminabilidad'),
      _CompRow('ED', n.ed, municipalData.ed, true, 'Equip. Deport.'),
      _CompRow('EAR', n.ear, municipalData.ear, false, 'Ent. Alim. Riesgoso'),
      _CompRow('IMP', n.imp, municipalData.imp, false, 'Marginación'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: const [
                SizedBox(
                  width: 80,
                  child: Text(
                    'Variable',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.muted,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Colonia',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Municipio',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.muted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    'Δ',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.muted,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          // Rows
          ...rows.asMap().entries.map((e) {
            final row = e.value;
            final isLast = e.key == rows.length - 1;
            final delta = row.colonia - row.municipio;
            final coloniaColor = _riskColor(row.colonia, inverse: row.inverse);
            final muniColor = _riskColor(row.municipio, inverse: row.inverse);
            // For delta: positive is good if inverse (higher AV = better), bad if !inverse
            final deltaGood = row.inverse ? delta > 0 : delta < 0;
            final deltaColor = delta == 0
                ? AppColors.muted
                : (deltaGood ? AppColors.low : AppColors.high);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : const Border(
                        bottom: BorderSide(color: AppColors.border),
                      ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.key,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        Text(
                          row.label,
                          style: const TextStyle(
                            fontSize: 8,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.colonia.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: coloniaColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.municipio.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: muniColor.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: deltaColor,
                      ),
                      textAlign: TextAlign.right,
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

  // ---- 6. Recommendations ----

  Widget _buildRecommendations(List<String> recs) {
    return Column(
      children: recs.asMap().entries.map((e) {
        final idx = e.key + 1;
        final rec = e.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$idx',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  rec,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.text,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ---- 7. Disclaimer ----

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.accent),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'El IARRI es una estimación poblacional basada en variables territoriales '
              '(INEGI / CONAPO / DENUE). No constituye diagnóstico médico individual. '
              'Consulta a tu médico para evaluación clínica personalizada.',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper: comparison row data
// ---------------------------------------------------------------------------

class _CompRow {
  final String key;
  final double colonia;
  final double municipio;
  final bool inverse;
  final String label;

  const _CompRow(
    this.key,
    this.colonia,
    this.municipio,
    this.inverse,
    this.label,
  );
}
