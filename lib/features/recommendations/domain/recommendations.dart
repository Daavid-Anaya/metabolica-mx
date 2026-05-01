import 'package:flutter/material.dart';
import 'package:metabolica_mx/config/app_colors.dart';

class Recommendation {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String icon;
  final Color color;
  final String category;
  final List<String> steps;
  final String estimatedImpact;
  final String omsRef;
  const Recommendation({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
    required this.steps,
    required this.estimatedImpact,
    required this.omsRef,
  });
}
/// Arquitectura Preventiva — 5 items alineados con el original Python (ARQ_PREVENTIVA)
const List<Recommendation> arqPreventiva = [
  Recommendation(
    id: 'ruta_peatonal',
    title: 'Ruta Peatonal Diaria',
    subtitle: '15–30 min caminados en tu colonia',
    description:
    'Diseñar una ruta peatonal personal y repetirla a diario activa el músculo '
        'sin necesitar instalaciones. La OMS recomienda al menos 150 min semanales '
        'de actividad física moderada — una caminata diaria de 20 min los cubre.',
    icon: '🚶',
    color: AppColors.accent,
    category: 'movimiento',
    steps: [
      'Identificá 2–3 rutas desde tu casa con banquetas accesibles.',
      'Fijá una hora fija (mañana o tarde) para crear hábito.',
      'Sumá 5 min cada semana hasta llegar a 30 min continuos.',
      'Registrá la ruta en un mapa y compartila con alguien de tu familia.',
    ],
    estimatedImpact: '↓ 30% riesgo diabetes tipo 2 con 30 min/día',
    omsRef: 'OMS — Actividad física: 150 min/sem moderada (2020)',
  ),
  Recommendation(
    id: 'rediseno_espacio',
    title: 'Rediseño de Patio o Vivienda',
    subtitle: 'Espacios que invitan al movimiento',
    description:
    'El diseño del hogar puede sumar o restar actividad física involuntaria. '
        'Reorganizar muebles, liberar pasillos y crear zonas activas dentro '
        'del hogar aumenta el movimiento espontáneo, especialmente en viviendas '
        'con espacio exterior limitado.',
    icon: '🏠',
    color: AppColors.accent3,
    category: 'diseño',
    steps: [
      'Liberá al menos 4 m² de espacio libre para estiramiento o ejercicio.',
      'Mové el escritorio/TV para que requieran levantarse con más frecuencia.',
      'Creá una zona de estiramiento con tapete y acceso a luz natural.',
      'Si tenés patio: habilitá un circuito corto (5 min) de caminata.',
    ],
    estimatedImpact: '+8–12% actividad física diaria sin esfuerzo consciente',
    omsRef: 'OMS — Ciudades saludables: entorno construido activo (2016)',
  ),
  Recommendation(
    id: 'ventilacion_luz',
    title: 'Ventilación y Luz Natural',
    subtitle: 'Neuroarquitectura aplicada al hogar',
    description:
    'La luz natural regula el ritmo circadiano y mejora el sueño — factor '
        'directo en la sensibilidad a la insulina. La ventilación cruzada '
        'reduce el CO₂ interior y el cortisol. Estudios de neuroarquitectura '
        'muestran reducciones de hasta 18% en marcadores de estrés.',
    icon: '🪟',
    color: AppColors.mid,
    category: 'diseño',
    steps: [
      'Abrí ventanas opuestas 10 min al día para ventilación cruzada.',
      'Exponete a luz solar directa dentro de la primera hora al despertar.',
      'Reubicá tu zona de trabajo cerca de la fuente de luz natural.',
      'Usá cortinas translúcidas en vez de opacas durante el día.',
    ],
    estimatedImpact: '↓ 18% cortisol — mejora de sueño y sensibilidad insulínica',
    omsRef: 'OMS — Calidad de aire en interiores y salud (2010)',
  ),
  Recommendation(
    id: 'microhuerto',
    title: 'Microhuerto Urbano',
    subtitle: 'Vegetales frescos a costo mínimo',
    description:
    'Un microhuerto en azotea, balcón o ventana provee acceso directo a '
        'vegetales frescos con bajo índice glucémico. Además, la actividad de '
        'jardinería urbana suma movimiento liviano diario y reduce el estrés. '
        'Es la intervención alimentaria de menor costo y mayor impacto en zonas '
        'con alto entorno alimentario riesgoso (EAR).',
    icon: '🌱',
    color: AppColors.low,
    category: 'nutricion',
    steps: [
      'Empezá con 3 plantas en macetas: jitomate, chile y hierba aromática.',
      'Ubicá las macetas en el espacio con más horas de sol directo.',
      'Dedicá 10 min diarios al riego — es actividad física y reducción de estrés.',
      'Expandí progresivamente con lechuga, espinaca o nopal.',
    ],
    estimatedImpact: '↑ consumo de fibra vegetal — ↓ índice glucémico de la dieta',
    omsRef: 'OMS — Agricultura urbana y seguridad alimentaria (2017)',
  ),
  Recommendation(
    id: 'escaleras_activas',
    title: 'Espacios Activos: Escaleras Visibles',
    subtitle: 'Arquitectura que suma pasos sin pensarlo',
    description:
    'Hacer que las escaleras sean el camino más obvio y atractivo incrementa '
        'su uso hasta en un 30% frente a los elevadores. Este principio de '
        '\'default activo\' es uno de los más estudiados por la OMS en intervenciones '
        'de entorno construido: no requiere motivación, solo buen diseño.',
    icon: '🏛️',
    color: AppColors.accent2,
    category: 'movimiento',
    steps: [
      'Si usás escaleras en tu edificio, priorizalas sobre el elevador siempre.',
      'En casa: colocá elementos que \'inviten\' a subir (plantas en escalones, iluminación).',
      'Proponé a tu edificio señalizar las escaleras con mensajes motivadores.',
      'Contá pisos subidos por semana como métrica de actividad.',
    ],
    estimatedImpact: '+30% uso de escaleras con diseño visible — +150 kcal/semana',
    omsRef: 'OMS — Entornos físicamente activos: evidencia y guías (2021)',
  ),
];
// ─── Intervenciones prioritarias ─────────────────────────────────────────────
// Lista base de intervenciones con la variable que atacan (para priorización)
class Intervention {
  final String icon;
  final String title;
  final String impact;
  final Color color;
  final String targetVar; // variable del modelo IARRI que ataca
  const Intervention({
    required this.icon,
    required this.title,
    required this.impact,
    required this.color,
    required this.targetVar,
  });
}
const List<Intervention> interventions = [
  Intervention(
    icon: '🌳',
    title: 'Incrementar Áreas Verdes',
    impact: '↓ IARRI −0.05 (−6.4%)',
    color: AppColors.low,
    targetVar: 'AV',
  ),
  Intervention(
    icon: '🚶',
    title: 'Ruta Diaria de 15 min',
    impact: '↓ IARRI −0.0625 (−8%)',
    color: AppColors.accent,
    targetVar: 'IC',
  ),
  Intervention(
    icon: '⚽',
    title: 'Espacios Deportivos',
    impact: '↓ IARRI −0.03 (−3.8%)',
    color: AppColors.accent3,
    targetVar: 'ED',
  ),
  Intervention(
    icon: '🏗️',
    title: 'Regulación Alimentaria',
    impact: '↓ IARRI −0.05 (−6.4%)',
    color: AppColors.accent2,
    targetVar: 'EAR',
  ),
  Intervention(
    icon: '🪟',
    title: 'Diseño Arquitectónico',
    impact: 'Compensación: +18%',
    color: AppColors.mid,
    targetVar: 'IMP',
  ),
];
// Variables protectoras: urgente cuando el valor es BAJO
const _inverseVars = {'AV', 'IC', 'ED'};
/// Mapeo: variable → intervención que la ataca primero
const _varToIntervention = {
  'AV': 'Incrementar Áreas Verdes',
  'IC': 'Ruta Diaria de 15 min',
  'ED': 'Espacios Deportivos',
  'EAR': 'Regulación Alimentaria',
  'IMP': 'Diseño Arquitectónico',
};
/// Retorna [interventions] ordenadas por urgencia descendente según los
/// valores actuales del usuario. La primera es la "PRIORITARIA".
/// Si [currentVars] es null retorna la lista en orden original.
List<Intervention> prioritizeInterventions(Map<String, double>? currentVars) {
  if (currentVars == null) return interventions;
  final urgency = <String, double>{};
  for (final entry in currentVars.entries) {
    final key = entry.key;
    final val = entry.value;
    urgency[key] = _inverseVars.contains(key) ? (1.0 - val) : val;
  }
  final titleToVar = {
    for (final e in _varToIntervention.entries) e.value: e.key,
  };
  final sorted = List<Intervention>.from(interventions)
    ..sort((a, b) {
      final varA = titleToVar[a.title];
      final varB = titleToVar[b.title];
      final uA = urgency[varA] ?? 0.5;
      final uB = urgency[varB] ?? 0.5;
      return uB.compareTo(uA); // descendente
    });
  return sorted;
}