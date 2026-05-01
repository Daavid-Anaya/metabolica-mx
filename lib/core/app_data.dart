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
