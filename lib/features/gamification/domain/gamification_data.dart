import 'package:flutter/material.dart';

class Challenge {
  final String id;
  final String category;
  final String emoji;
  final Color color;
  final String title;
  final String description;
  final String instruction;
  final int meta;
  final String unit;
  final int xp;
  final String? badgeId;
  final int semana;
  final List<String> steps;

  const Challenge({
    required this.id,
    required this.category,
    required this.emoji,
    required this.color,
    required this.title,
    required this.description,
    required this.instruction,
    required this.meta,
    required this.unit,
    required this.xp,
    this.badgeId,
    required this.semana,
    required this.steps,
  });
}

class Badge {
  final String id;
  final String emoji;
  final String name;
  final String description;
  final Color color;
  final String conditionType;
  final String conditionKey;
  final dynamic conditionValue;
  final int xpBonus;
  final String category;

  const Badge({
    required this.id,
    required this.emoji,
    required this.name,
    required this.description,
    required this.color,
    required this.conditionType,
    required this.conditionKey,
    this.conditionValue,
    required this.xpBonus,
    required this.category,
  });
}

const List<Challenge> weeklyChallenges = [
  // Semana 1
  Challenge(
    id: "camina_colonia",
    category: "movimiento",
    emoji: "🚶",
    color: Color(0xFF0EA5E9),
    title: "Camina 5 000 pasos en tu colonia",
    description: "Sal a caminar por tu colonia durante al menos 40 minutos. Observa las banquetas, áreas verdes y equipamiento deportivo cerca de tu casa.",
    instruction: "Registra cada día que completaste tu caminata",
    meta: 5,
    unit: "días",
    xp: 80,
    badgeId: "arquitecto_bioactivo",
    semana: 1,
    steps: [
      "Sal a caminar al menos 40 minutos",
      "Recorre un área verde o parque de tu colonia",
      "Identifica una banqueta en mal estado y fotográfiala",
      "Nota cuántas tiendas de ultraprocesados hay en tu ruta",
      "Comparte el recorrido con alguien de tu familia",
    ],
  ),
  Challenge(
    id: "desayuno_real",
    category: "nutricion",
    emoji: "🥗",
    color: Color(0xFF22C55E),
    title: "3 días sin ultraprocesados al desayuno",
    description: "Reemplaza los cereales azucarados, pan dulce o galletas por frutas, avena o huevo durante 3 mañanas consecutivas.",
    instruction: "Marca cada mañana que lo lograste",
    meta: 3,
    unit: "días",
    xp: 60,
    badgeId: null,
    semana: 1,
    steps: [
      "Prepara avena con fruta el lunes",
      "Huevo con verduras el miércoles",
      "Fruta fresca con nueces el viernes",
    ],
  ),
  // Semana 2
  Challenge(
    id: "redisena_estudio",
    category: "diseño",
    emoji: "🛋️",
    color: Color(0xFF8B5CF6),
    title: "Rediseña tu espacio de estudio",
    description: "Aplica 3 principios de arquitectura preventiva en tu área de trabajo o estudio: luz natural, ventilación y una planta o elemento verde.",
    instruction: "Completa cada mejora y márcala",
    meta: 3,
    unit: "acciones",
    xp: 100,
    badgeId: "disenador_preventivo",
    semana: 2,
    steps: [
      "Mueve tu escritorio cerca de una ventana con luz natural",
      "Asegura ventilación cruzada: abre ventanas opuestas 10 min al día",
      "Agrega una planta pequeña (suculenta, pothos o albahaca) a tu espacio",
    ],
  ),
  Challenge(
    id: "mapea_colonia",
    category: "territorio",
    emoji: "🗺️",
    color: Color(0xFFF59E0B),
    title: "Mapea los riesgos de tu colonia",
    description: "Usa el módulo de Mapa para revisar el perfil territorial de tu colonia. Identifica las 2 variables con peor puntaje y piensa en una solución concreta.",
    instruction: "Completa los pasos de análisis",
    meta: 3,
    unit: "acciones",
    xp: 70,
    badgeId: null,
    semana: 2,
    steps: [
      "Abre el módulo Mapa y selecciona tu colonia",
      "Identifica las 2 variables con ✖ Crítico",
      "Escribe en papel una acción concreta para mejorar cada variable",
    ],
  ),
  // Semana 3
  Challenge(
    id: "completa_microcurso",
    category: "educacion",
    emoji: "🔬",
    color: Color(0xFF0EA5E9),
    title: "Completa un microcurso completo",
    description: "Termina todas las lecciones y la evaluación de cualquier microcurso en el módulo Educación.",
    instruction: "Completa lecciones y evaluación",
    meta: 1,
    unit: "microcurso",
    xp: 120,
    badgeId: "agente_metabolico",
    semana: 3,
    steps: [
      "Elige un microcurso en el módulo Aprender",
      "Completa todas sus lecciones",
      "Aprueba la evaluación final",
    ],
  ),
  Challenge(
    id: "calcula_iarri",
    category: "territorio",
    emoji: "📊",
    color: Color(0xFFF97316),
    title: "Calcula tu IARRI personal",
    description: "Usa la Calculadora IARRI con tus valores reales y guarda el resultado. Compara con el promedio de tu municipio.",
    instruction: "Guarda un cálculo en la Calculadora",
    meta: 1,
    unit: "cálculo",
    xp: 50,
    badgeId: "analista_territorial",
    semana: 3,
    steps: [
      "Abre la Calculadora IARRI",
      "Ajusta los sliders con tus valores reales",
      "Guarda el resultado con el botón 'Guardar'",
    ],
  ),
  // Semana 4
  Challenge(
    id: "semana_activa",
    category: "movimiento",
    emoji: "⚡",
    color: Color(0xFFEF4444),
    title: "Semana activa — 7 días de movimiento",
    description: "El reto más completo: combina caminata diaria, un día de ejercicio de fuerza y tres días sin ultraprocesados en una sola semana.",
    instruction: "Registra cada día que cumpliste al menos uno de los criterios",
    meta: 7,
    unit: "días",
    xp: 200,
    badgeId: "investigador_iarri",
    semana: 4,
    steps: [
      "Lunes: caminata 40 min",
      "Martes: desayuno sin ultraprocesados",
      "Miércoles: ejercicio de fuerza (sentadillas, lagartijas) 20 min",
      "Jueves: caminata 40 min",
      "Viernes: desayuno sin ultraprocesados",
      "Sábado: recorre un parque o área verde con familia",
      "Domingo: planea la semana siguiente con los módulos de la app",
    ],
  ),
];

const List<Badge> gamificationBadges = [
  Badge(
    id: "arquitecto_bioactivo",
    emoji: "🏙️",
    name: "Arquitecto Bioactivo",
    description: "Completaste el reto de caminata semanal. Conoces tu colonia y la recorres activamente.",
    color: Color(0xFF0EA5E9),
    conditionType: "reto",
    conditionKey: "camina_colonia",
    xpBonus: 50,
    category: "movimiento",
  ),
  Badge(
    id: "disenador_preventivo",
    emoji: "🌱",
    name: "Diseñador Preventivo",
    description: "Aplicaste arquitectura preventiva en tu espacio. Tu entorno ahora trabaja a favor de tu salud.",
    color: Color(0xFF22C55E),
    conditionType: "reto",
    conditionKey: "redisena_estudio",
    xpBonus: 60,
    category: "diseño",
  ),
  Badge(
    id: "agente_metabolico",
    emoji: "⚡",
    name: "Agente Metabólico",
    description: "Completaste un microcurso completo. Tienes el conocimiento para actuar sobre tu entorno metabólico.",
    color: Color(0xFF8B5CF6),
    conditionType: "reto",
    conditionKey: "completa_microcurso",
    xpBonus: 80,
    category: "educacion",
  ),
  Badge(
    id: "analista_territorial",
    emoji: "📊",
    name: "Analista Territorial",
    description: "Guardaste tu cálculo IARRI personal. Ya mediste tu riesgo metabólico con datos reales.",
    color: Color(0xFFF97316),
    conditionType: "bool",
    conditionKey: "iarri_guardado",
    xpBonus: 40,
    category: "territorio",
  ),
  Badge(
    id: "mapeador_urbano",
    emoji: "🗺️",
    name: "Mapeador Urbano",
    description: "Completaste el reto territorial y conoces los riesgos de tu colonia.",
    color: Color(0xFFF59E0B),
    conditionType: "reto",
    conditionKey: "mapea_colonia",
    xpBonus: 40,
    category: "territorio",
  ),
  Badge(
    id: "investigador_iarri",
    emoji: "🔬",
    name: "Investigador IARRI",
    description: "Completaste la Semana Activa de 7 días. Sos un referente de salud metabólica preventiva.",
    color: Color(0xFFEF4444),
    conditionType: "reto",
    conditionKey: "semana_activa",
    xpBonus: 120,
    category: "movimiento",
  ),
  Badge(
    id: "experto_educacion",
    emoji: "🎓",
    name: "Experto en Educación",
    description: "Completaste todos los microcursos del módulo Educación.",
    color: Color(0xFF0EA5E9),
    conditionType: "gte",
    conditionKey: "microcursos_completados",
    conditionValue: 4,
    xpBonus: 200,
    category: "educacion",
  ),
];
