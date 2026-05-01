class Municipality {
  final String name;
  final double av;
  final double ic;
  final double ed;
  final double ear;
  final double imp;

  const Municipality({
    required this.name,
    required this.av,
    required this.ic,
    required this.ed,
    required this.ear,
    required this.imp,
  });
}

const List<Municipality> municipios = [
  Municipality(
      name: "San Andrés Cholula",
      av: 0.80,
      ic: 0.60,
      ed: 0.40,
      ear: 0.45,
      imp: 0.10),
  Municipality(
      name: "San Pablo Xochimehuacan",
      av: 0.50,
      ic: 0.35,
      ed: 0.20,
      ear: 0.60,
      imp: 0.55),
  Municipality(
      name: "Cuautlancingo",
      av: 0.30,
      ic: 0.20,
      ed: 0.10,
      ear: 0.80,
      imp: 0.70),
];

class TerritorialVariable {
  final String key;
  final String label;
  final String icon;
  final int colorValue;
  final bool isInverse;
  final String description;

  const TerritorialVariable({
    required this.key,
    required this.label,
    required this.icon,
    required this.colorValue,
    required this.isInverse,
    required this.description,
  });
}

const List<TerritorialVariable> territorialVariables = [
  TerritorialVariable(
      key: "AV",
      label: "Áreas Verdes",
      icon: "🌳",
      colorValue: 0xFF22C55E,
      isInverse: true,
      description: "Estándar OMS 9 m²/hab"),
  TerritorialVariable(
      key: "IC",
      label: "Índice Caminabilidad",
      icon: "🚶",
      colorValue: 0xFF0EA5E9,
      isInverse: true,
      description: "Intersecciones + banquetas"),
  TerritorialVariable(
      key: "ED",
      label: "Equipamiento Deportivo",
      icon: "⚽",
      colorValue: 0xFF8B5CF6,
      isInverse: true,
      description: "Equipamientos / población"),
  TerritorialVariable(
      key: "EAR",
      label: "Entorno Alimentario Riesgoso",
      icon: "🍟",
      colorValue: 0xFFF97316,
      isInverse: false,
      description: "Tiendas ultraprocesados / total"),
  TerritorialVariable(
      key: "IMP",
      label: "Índice de Marginación",
      icon: "📉",
      colorValue: 0xFFF59E0B,
      isInverse: false,
      description: "CONAPO normalizado"),
];

// ─── Variables IARM ───────────────────────────────────────────────────────────
// Los 4 factores del IARM — todos de riesgo DIRECTO: mayor valor = mayor riesgo.

class IarmVariable {
  final String key;
  final String label;
  final String icon;
  final int colorValue;
  final String description;

  const IarmVariable({
    required this.key,
    required this.label,
    required this.icon,
    required this.colorValue,
    required this.description,
  });
}

const List<IarmVariable> iarmVariables = [
  IarmVariable(
    key: "ST",
    label: "Sedentarismo Territorial",
    icon: "🪑",
    colorValue: 0xFFEF4444,
    description: "% población sin actividad física en la zona",
  ),
  IarmVariable(
    key: "BAV",
    label: "Baja Área Verde",
    icon: "🏜️",
    colorValue: 0xFFF97316,
    description: "Déficit de m² de área verde por habitante",
  ),
  IarmVariable(
    key: "DEN",
    label: "Alta Densidad Poblacional",
    icon: "🏙️",
    colorValue: 0xFFF59E0B,
    description: "Hab/km² normalizado respecto al máximo municipal",
  ),
  IarmVariable(
    key: "BEA",
    label: "Bajo Equipamiento Activo",
    icon: "🚫",
    colorValue: 0xFF8B5CF6,
    description: "Déficit de instalaciones deportivas / 10k hab",
  ),
];

// ─── Recomendaciones IARM ─────────────────────────────────────────────────────
// Acciones e intervenciones según nivel de riesgo del IARM.

class IarmRecommendation {
  final String icon;
  final int colorValue;
  final String title;
  final List<String> items;

  const IarmRecommendation({
    required this.icon,
    required this.colorValue,
    required this.title,
    required this.items,
  });
}

const Map<String, IarmRecommendation> iarmRecommendations = {
  'Bajo riesgo ambiental': IarmRecommendation(
    icon: '✅',
    colorValue: 0xFF22C55E,
    title: 'Entorno favorable — mantener y reforzar',
    items: [
      'Documentar las buenas prácticas de diseño urbano existentes.',
      'Promover la actividad física espontánea aprovechando la infraestructura actual.',
      'Participar en programas de mantenimiento de áreas verdes y equipamiento.',
    ],
  ),
  'Riesgo medio': IarmRecommendation(
    icon: '🟡',
    colorValue: 0xFFF59E0B,
    title: 'Intervención preventiva recomendada',
    items: [
      'Identificar los 2 factores con peor puntaje y priorizar su mejora.',
      'Gestionar ante autoridades la ampliación de áreas verdes en déficit.',
      'Proponer rutas peatonales seguras para reducir sedentarismo territorial.',
      'Revisar densificación urbana y su impacto en calidad de vida activa.',
    ],
  ),
  'Alto riesgo': IarmRecommendation(
    icon: '🚨',
    colorValue: 0xFFEF4444,
    title: 'Alerta — intervención urgente requerida',
    items: [
      'Gestión urgente de equipamiento deportivo: al menos 2 unidades barriales.',
      'Plan emergente de áreas verdes: mínimo 1 parque de bolsillo por colonia.',
      'Reducción de densidad en nuevos desarrollos mediante normativa.',
      'Programa municipal de activación física con incentivos comunitarios.',
      'Diagnóstico participativo con residentes para co-diseñar intervenciones.',
    ],
  ),
};
