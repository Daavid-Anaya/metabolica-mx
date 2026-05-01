import 'package:flutter/material.dart';
import '../../../core/iarri_logic.dart';

// ---------------------------------------------------------------------------
// POI model
// ---------------------------------------------------------------------------

enum PoiType { verde, deporte, peatonal, ultra }

class Poi {
  final double lat;
  final double lon;
  final PoiType type;
  final String title;
  final String description;

  const Poi({
    required this.lat,
    required this.lon,
    required this.type,
    required this.title,
    required this.description,
  });
}

const Map<PoiType, ({String color, String emoji})> poiTypeConfig = {
  PoiType.verde:    (color: '#22c55e', emoji: '🌳'),
  PoiType.deporte:  (color: '#8b5cf6', emoji: '⚽'),
  PoiType.peatonal: (color: '#0ea5e9', emoji: '🚶'),
  PoiType.ultra:    (color: '#ef4444', emoji: '🍟'),
};

// ---------------------------------------------------------------------------
// Neighborhood model
// ---------------------------------------------------------------------------

class Neighborhood {
  final String name;
  final double iarri;
  final double av;
  final double ic;
  final double ed;
  final double ear;
  final double imp;
  final int population;
  final int density;
  final double greenAreasM2;
  final double mobility;
  final double sportsEquip;
  final double ultraprocessed;
  final double marginacion;
  final String marginacionGrade;
  final String description;

  const Neighborhood({
    required this.name,
    required this.iarri,
    required this.av,
    required this.ic,
    required this.ed,
    required this.ear,
    required this.imp,
    required this.population,
    required this.density,
    required this.greenAreasM2,
    required this.mobility,
    required this.sportsEquip,
    required this.ultraprocessed,
    required this.marginacion,
    required this.marginacionGrade,
    required this.description,
  });
}

// ---------------------------------------------------------------------------
// Municipality model
// ---------------------------------------------------------------------------

class MunicipalityTerritorialData {
  final String name;
  final double lat;
  final double lon;
  final int density;
  final int densityMax;
  final double greenAreasM2;
  final double omsStandard;
  final double marginacion;
  final double sportsEquip;
  final double sportsEquipIdeal;
  final double mobility;
  final double ultraprocessed;
  final int population;
  // IARRI components
  final double av;
  final double ic;
  final double ed;
  final double ear;
  final double imp;
  final List<Neighborhood> neighborhoods;
  final List<Poi> pois;

  const MunicipalityTerritorialData({
    required this.name,
    required this.lat,
    required this.lon,
    required this.density,
    required this.densityMax,
    required this.greenAreasM2,
    required this.omsStandard,
    required this.marginacion,
    required this.sportsEquip,
    required this.sportsEquipIdeal,
    required this.mobility,
    required this.ultraprocessed,
    required this.population,
    required this.av,
    required this.ic,
    required this.ed,
    required this.ear,
    required this.imp,
    required this.neighborhoods,
    required this.pois,
  });
}

// ---------------------------------------------------------------------------
// Neighborhood diagnosis model
// ---------------------------------------------------------------------------

class NeighborhoodAlert {
  final String emoji;
  final Color color;
  final String text;
  final String impact;

  const NeighborhoodAlert({
    required this.emoji,
    required this.color,
    required this.text,
    required this.impact,
  });
}

class NeighborhoodDiagnosis {
  final String level;
  final String title;
  final String subtitle;
  final List<NeighborhoodAlert> alerts;
  final List<NeighborhoodAlert> strengths;
  final List<String> recommendations;
  final double iarri;
  final double probRI;

  const NeighborhoodDiagnosis({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.alerts,
    required this.strengths,
    required this.recommendations,
    required this.iarri,
    required this.probRI,
  });
}

/// Mirrors `_diagnostico_colonia()` from Python mapa_screen.py.
NeighborhoodDiagnosis diagnoseNeighborhood(Neighborhood n) {
  final alerts = <NeighborhoodAlert>[];
  final strengths = <NeighborhoodAlert>[];

  // Áreas verdes
  if (n.greenAreasM2 < 3.0) {
    alerts.add(const NeighborhoodAlert(
      emoji: '🌳',
      color: Color(0xFFEF4444),
      text: 'Déficit crítico de áreas verdes',
      impact: '${3.0} m²/hab (mín OMS: 9)',
    ));
  } else if (n.greenAreasM2 < 6.0) {
    alerts.add(NeighborhoodAlert(
      emoji: '🌳',
      color: const Color(0xFFF59E0B),
      text: 'Áreas verdes insuficientes',
      impact: '${n.greenAreasM2.toStringAsFixed(1)} m²/hab (mín OMS: 9)',
    ));
  } else {
    strengths.add(NeighborhoodAlert(
      emoji: '🌳',
      color: const Color(0xFF22C55E),
      text: 'Áreas verdes adecuadas',
      impact: '${n.greenAreasM2.toStringAsFixed(1)} m²/hab',
    ));
  }

  // Movilidad peatonal
  if (n.mobility < 0.30) {
    alerts.add(const NeighborhoodAlert(
      emoji: '🚶',
      color: Color(0xFFEF4444),
      text: 'Caminabilidad crítica',
      impact: 'IC muy bajo — barrio poco peatonal',
    ));
  } else if (n.mobility < 0.55) {
    alerts.add(NeighborhoodAlert(
      emoji: '🚶',
      color: const Color(0xFFF59E0B),
      text: 'Caminabilidad deficiente',
      impact: 'IC ${n.mobility.toStringAsFixed(2)}',
    ));
  } else {
    strengths.add(NeighborhoodAlert(
      emoji: '🚶',
      color: const Color(0xFF22C55E),
      text: 'Buena caminabilidad',
      impact: 'IC ${n.mobility.toStringAsFixed(2)}',
    ));
  }

  // Equipamiento deportivo
  if (n.sportsEquip < 1.0) {
    alerts.add(const NeighborhoodAlert(
      emoji: '⚽',
      color: Color(0xFFEF4444),
      text: 'Equipamiento deportivo crítico',
      impact: 'Muy por debajo del estándar',
    ));
  } else if (n.sportsEquip < 3.0) {
    alerts.add(NeighborhoodAlert(
      emoji: '⚽',
      color: const Color(0xFFF59E0B),
      text: 'Equipamiento deportivo insuficiente',
      impact: '${n.sportsEquip.toStringAsFixed(1)} (ideal: 6)',
    ));
  } else {
    strengths.add(NeighborhoodAlert(
      emoji: '⚽',
      color: const Color(0xFF22C55E),
      text: 'Equipamiento deportivo aceptable',
      impact: '${n.sportsEquip.toStringAsFixed(1)} equipamientos',
    ));
  }

  // Tiendas / entorno alimentario riesgoso
  if (n.ultraprocessed > 0.70) {
    alerts.add(NeighborhoodAlert(
      emoji: '🍟',
      color: const Color(0xFFEF4444),
      text: 'Entorno alimentario muy riesgoso',
      impact: 'EAR ${n.ultraprocessed.toStringAsFixed(2)}',
    ));
  } else if (n.ultraprocessed > 0.45) {
    alerts.add(NeighborhoodAlert(
      emoji: '🍟',
      color: const Color(0xFFF59E0B),
      text: 'Entorno alimentario moderadamente riesgoso',
      impact: 'EAR ${n.ultraprocessed.toStringAsFixed(2)}',
    ));
  } else {
    strengths.add(NeighborhoodAlert(
      emoji: '🍟',
      color: const Color(0xFF22C55E),
      text: 'Entorno alimentario controlado',
      impact: 'EAR ${n.ultraprocessed.toStringAsFixed(2)}',
    ));
  }

  // Marginación
  if (n.marginacion > 0.60) {
    alerts.add(NeighborhoodAlert(
      emoji: '⚠️',
      color: const Color(0xFFEF4444),
      text: 'Marginación alta',
      impact: 'IMP ${n.marginacion.toStringAsFixed(2)}',
    ));
  } else if (n.marginacion > 0.30) {
    alerts.add(NeighborhoodAlert(
      emoji: '⚠️',
      color: const Color(0xFFF59E0B),
      text: 'Marginación media',
      impact: 'IMP ${n.marginacion.toStringAsFixed(2)}',
    ));
  } else {
    strengths.add(NeighborhoodAlert(
      emoji: '✅',
      color: const Color(0xFF22C55E),
      text: 'Baja marginación',
      impact: 'IMP ${n.marginacion.toStringAsFixed(2)}',
    ));
  }

  // Densidad poblacional
  if (n.density > 10000) {
    alerts.add(NeighborhoodAlert(
      emoji: '🏘️',
      color: const Color(0xFFF59E0B),
      text: 'Alta densidad poblacional',
      impact: '${n.density} hab/km²',
    ));
  } else {
    strengths.add(NeighborhoodAlert(
      emoji: '🏘️',
      color: const Color(0xFF22C55E),
      text: 'Densidad poblacional adecuada',
      impact: '${n.density} hab/km²',
    ));
  }

  // Recommendations — always includes IARRI tip
  final recommendations = <String>[
    '📊 Usa la Calculadora IARRI para simular mejoras en tu entorno',
  ];

  // Overall level based on IARRI
  final iarri = n.iarri;
  final String level;
  if (iarri >= 0.70) {
    level = 'crítico';
  } else if (iarri >= 0.50) {
    level = 'alto';
  } else if (iarri >= 0.35) {
    level = 'medio';
  } else {
    level = 'bajo';
  }

  final probRI = IARRILogic.calculateProbRI(iarri);

  return NeighborhoodDiagnosis(
    level: level,
    title: n.name,
    subtitle: 'Riesgo $level · IARRI ${iarri.toStringAsFixed(2)}',
    alerts: alerts,
    strengths: strengths,
    recommendations: recommendations,
    iarri: iarri,
    probRI: probRI,
  );
}

// ---------------------------------------------------------------------------
// Territorial data
// ---------------------------------------------------------------------------

const Map<String, MunicipalityTerritorialData> territorialData = {
  "San Andrés Cholula": MunicipalityTerritorialData(
    name: "San Andrés Cholula",
    lat: 19.0514,
    lon: -98.3020,
    density: 4800,
    densityMax: 12000,
    greenAreasM2: 6.2,
    omsStandard: 9.0,
    marginacion: 0.10,
    sportsEquip: 3.8,
    sportsEquipIdeal: 6.0,
    mobility: 0.62,
    ultraprocessed: 0.41,
    population: 115613,
    av: 0.68,
    ic: 0.60,
    ed: 0.55,
    ear: 0.42,
    imp: 0.10,
    neighborhoods: [
      Neighborhood(
        name: "San Andrés Cholula Centro",
        iarri: 0.28,
        av: 0.85,
        ic: 0.70,
        ed: 0.75,
        ear: 0.30,
        imp: 0.08,
        population: 18200,
        density: 3800,
        greenAreasM2: 8.2,
        mobility: 0.78,
        sportsEquip: 5.2,
        ultraprocessed: 0.30,
        marginacion: 0.08,
        marginacionGrade: "Muy bajo",
        description: "Zona histórica con buena infraestructura peatonal y parques.",
      ),
      Neighborhood(
        name: "Ex-Hacienda Zavaleta",
        iarri: 0.34,
        av: 0.65,
        ic: 0.60,
        ed: 0.55,
        ear: 0.40,
        imp: 0.12,
        population: 22400,
        density: 5200,
        greenAreasM2: 5.8,
        mobility: 0.62,
        sportsEquip: 3.8,
        ultraprocessed: 0.42,
        marginacion: 0.12,
        marginacionGrade: "Muy bajo",
        description: "Zona residencial de ingresos medios-altos con servicios cercanos.",
      ),
    ],
    pois: [
      Poi(
        lat: 19.0540,
        lon: -98.3060,
        type: PoiType.verde,
        title: "Parque Paseo Cholula",
        description: "Área verde · AV +0.12",
      ),
      Poi(
        lat: 19.0490,
        lon: -98.2980,
        type: PoiType.verde,
        title: "Jardines de Zavaleta",
        description: "Corredor verde · AV +0.08",
      ),
      Poi(
        lat: 19.0500,
        lon: -98.3035,
        type: PoiType.deporte,
        title: "Unidad Deportiva SAC",
        description: "Canchas y gimnasio · ED +0.10",
      ),
      Poi(
        lat: 19.0475,
        lon: -98.3040,
        type: PoiType.peatonal,
        title: "Zona Peatonal Centro",
        description: "Caminabilidad alta · IC +0.15",
      ),
      Poi(
        lat: 19.0530,
        lon: -98.2990,
        type: PoiType.ultra,
        title: "Zona Comercial Galerías",
        description: "Ultraprocesados densos",
      ),
    ],
  ),
  "San Pablo Xochimehuacan": MunicipalityTerritorialData(
    name: "San Pablo Xochimehuacan",
    lat: 19.0310,
    lon: -98.2360,
    density: 8500,
    densityMax: 12000,
    greenAreasM2: 2.8,
    omsStandard: 9.0,
    marginacion: 0.55,
    sportsEquip: 1.2,
    sportsEquipIdeal: 6.0,
    mobility: 0.35,
    ultraprocessed: 0.60,
    population: 185000,
    av: 0.30,
    ic: 0.35,
    ed: 0.15,
    ear: 0.65,
    imp: 0.55,
    neighborhoods: [
      Neighborhood(
        name: "Santa María la Rivera",
        iarri: 0.62,
        av: 0.40,
        ic: 0.30,
        ed: 0.15,
        ear: 0.65,
        imp: 0.50,
        population: 12500,
        density: 9200,
        greenAreasM2: 2.1,
        mobility: 0.28,
        sportsEquip: 0.8,
        ultraprocessed: 0.68,
        marginacion: 0.52,
        marginacionGrade: "Medio",
        description: "Zona de alta densidad con déficit de equipamiento y áreas verdes.",
      ),
    ],
    pois: [
      Poi(
        lat: 19.0320,
        lon: -98.2350,
        type: PoiType.ultra,
        title: "Corredor Comercial",
        description: "Tiendas · EAR +0.18",
      ),
      Poi(
        lat: 19.0290,
        lon: -98.2380,
        type: PoiType.verde,
        title: "Área verde escasa",
        description: "Solo 2.8 m²/hab",
      ),
      Poi(
        lat: 19.0310,
        lon: -98.2340,
        type: PoiType.deporte,
        title: "Campo Municipal",
        description: "ED básico",
      ),
    ],
  ),
  "Cuautlancingo": MunicipalityTerritorialData(
    name: "Cuautlancingo",
    lat: 19.0897,
    lon: -98.2730,
    density: 6200,
    densityMax: 12000,
    greenAreasM2: 3.5,
    omsStandard: 9.0,
    marginacion: 0.70,
    sportsEquip: 1.8,
    sportsEquipIdeal: 6.0,
    mobility: 0.25,
    ultraprocessed: 0.80,
    population: 137435,
    av: 0.22,
    ic: 0.20,
    ed: 0.08,
    ear: 0.80,
    imp: 0.70,
    neighborhoods: [
      Neighborhood(
        name: "Fuerza Territorial",
        iarri: 0.75,
        av: 0.20,
        ic: 0.15,
        ed: 0.10,
        ear: 0.85,
        imp: 0.75,
        population: 8900,
        density: 7800,
        greenAreasM2: 1.2,
        mobility: 0.18,
        sportsEquip: 0.5,
        ultraprocessed: 0.82,
        marginacion: 0.78,
        marginacionGrade: "Alto",
        description: "Entorno industrial con alto riesgo ambiental y alimentario.",
      ),
    ],
    pois: [
      Poi(
        lat: 19.0920,
        lon: -98.2750,
        type: PoiType.ultra,
        title: "Corredor OXXO/7Eleven",
        description: "EAR +0.22",
      ),
      Poi(
        lat: 19.0880,
        lon: -98.2710,
        type: PoiType.ultra,
        title: "Zona Industrial",
        description: "Ultraprocesados",
      ),
      Poi(
        lat: 19.0897,
        lon: -98.2730,
        type: PoiType.deporte,
        title: "Campo Municipal",
        description: "ED 0.08",
      ),
      Poi(
        lat: 19.0870,
        lon: -98.2760,
        type: PoiType.verde,
        title: "Área verde crítica",
        description: "Solo 1.1 m²/hab",
      ),
    ],
  ),
};

// ---------------------------------------------------------------------------
// Map state
// ---------------------------------------------------------------------------

class MapState {
  final String selectedMunicipality;
  final Neighborhood? selectedNeighborhood;

  MapState({
    required this.selectedMunicipality,
    this.selectedNeighborhood,
  });

  factory MapState.initial() {
    return MapState(selectedMunicipality: "San Andrés Cholula");
  }

  MapState copyWith({
    String? selectedMunicipality,
    Neighborhood? selectedNeighborhood,
    bool clearNeighborhood = false,
  }) {
    return MapState(
      selectedMunicipality: selectedMunicipality ?? this.selectedMunicipality,
      selectedNeighborhood: clearNeighborhood
          ? null
          : (selectedNeighborhood ?? this.selectedNeighborhood),
    );
  }
}
