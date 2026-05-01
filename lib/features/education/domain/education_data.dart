// ─── MODELOS ──────────────────────────────────────────────────────────────────

class LessonSection {
  final String title;
  final String content;

  const LessonSection({required this.title, required this.content});
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

class EvalQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final int xp;

  const EvalQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.xp,
  });
}

class Lesson {
  final int id;
  final String title;
  final String emoji;
  final int colorValue;
  final List<LessonSection> sections;
  final List<QuizQuestion> quiz;

  const Lesson({
    required this.id,
    required this.title,
    required this.emoji,
    required this.colorValue,
    required this.sections,
    required this.quiz,
  });
}

class Microcourse {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int colorValue;
  final String levelName;
  final int totalXp;
  final String badgeEmoji;
  final String badgeName;
  final List<int> lessonIds;
  final String evalTitle;
  final String evalDescription;
  final List<EvalQuestion> evalQuestions;

  const Microcourse({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.colorValue,
    required this.levelName,
    required this.totalXp,
    required this.badgeEmoji,
    required this.badgeName,
    required this.lessonIds,
    required this.evalTitle,
    required this.evalDescription,
    required this.evalQuestions,
  });
}

class XpLevel {
  final int level;
  final String title;
  final int xpMin;
  final String emoji;

  const XpLevel({
    required this.level,
    required this.title,
    required this.xpMin,
    required this.emoji,
  });
}

// ─── CONSTANTES DE COLOR ──────────────────────────────────────────────────────

const int _accent  = 0xFF0EA5E9; // Azul cielo
const int _accent3 = 0xFF8B5CF6; // Violeta
const int _low     = 0xFF22C55E; // Verde
const int _mid     = 0xFFF59E0B; // Ámbar

// ─── NIVELES DE XP ────────────────────────────────────────────────────────────

const List<XpLevel> xpLevels = [
  XpLevel(level: 1, title: 'Aprendiz',       xpMin: 0,   emoji: '🌱'),
  XpLevel(level: 2, title: 'Explorador',      xpMin: 100, emoji: '🔍'),
  XpLevel(level: 3, title: 'Investigador',    xpMin: 250, emoji: '🔬'),
  XpLevel(level: 4, title: 'Analista Urbano', xpMin: 450, emoji: '🏙️'),
  XpLevel(level: 5, title: 'Experto IARRI',   xpMin: 700, emoji: '⭐'),
];

// ─── LECCIONES ────────────────────────────────────────────────────────────────

const List<Lesson> lessons = [
  // Lección 0 — ¿Qué es la Resistencia a la Insulina?
  Lesson(
    id: 0,
    title: '¿Qué es la Resistencia a la Insulina?',
    emoji: '🔬',
    colorValue: _accent,
    sections: [
      LessonSection(
        title: '¿Qué es la insulina?',
        content:
            'La insulina es una hormona producida por el páncreas. Su función es permitir que el azúcar (glucosa) de los alimentos entre a las células para usarse como energía.',
      ),
      LessonSection(
        title: '¿Qué pasa con la resistencia?',
        content:
            'Cuando las células dejan de responder bien a la insulina, el páncreas produce cada vez más para compensar. Con el tiempo esto puede llevar a prediabetes y diabetes tipo 2.',
      ),
      LessonSection(
        title: '¿Es común?',
        content:
            'En México, más del 30% de la población adulta tiene algún grado de resistencia a la insulina, muchas veces sin saberlo.',
      ),
      LessonSection(
        title: 'Señales de alerta',
        content:
            'Cansancio después de comer, antojos de azúcar, dificultad para bajar de peso en el abdomen y piel oscura en cuello o axilas (acantosis nigricans).',
      ),
    ],
    quiz: [
      QuizQuestion(
        question: '¿Cuál es la función principal de la insulina?',
        options: [
          'Quemar grasa directamente',
          'Permitir que la glucosa entre a las células',
          'Producir energía en el páncreas',
          'Regular la presión arterial',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        question: '¿Cómo se llama la mancha oscura en cuello/axilas?',
        options: ['Melanoma', 'Acantosis nigricans', 'Dermatitis', 'Psoriasis'],
        correctIndex: 1,
      ),
      QuizQuestion(
        question:
            '¿Qué porcentaje aprox. de adultos en México tiene resistencia a la insulina?',
        options: ['5%', '10%', '30%', '60%'],
        correctIndex: 2,
      ),
    ],
  ),

  // Lección 1 — Entorno Urbano y Metabolismo
  Lesson(
    id: 1,
    title: 'Entorno Urbano y Metabolismo',
    emoji: '🏙️',
    colorValue: _accent3,
    sections: [
      LessonSection(
        title: 'El entorno construido afecta tu salud',
        content:
            'El lugar donde vives influye directamente en tu metabolismo. Las ciudades diseñadas para el auto, sin banquetas ni áreas verdes, promueven el sedentarismo.',
      ),
      LessonSection(
        title: 'Áreas verdes y actividad física',
        content:
            'Según la OMS, cada habitante debería tener acceso a 9 m² de área verde. En municipios como Cuautlancingo este valor es muy bajo, reduciendo la actividad física espontánea.',
      ),
      LessonSection(
        title: 'Entorno alimentario riesgoso',
        content:
            'La alta densidad de tiendas de ultraprocesados en una colonia aumenta el consumo de azúcar y grasas trans, factores directos de resistencia a la insulina.',
      ),
      LessonSection(
        title: 'Índice IARRI-MX',
        content:
            'Este índice mide el riesgo metabólico de tu municipio combinando: acceso a áreas verdes, caminabilidad, equipamiento deportivo, entorno alimentario e índice de marginación.',
      ),
    ],
    quiz: [
      QuizQuestion(
        question: '¿Cuántos m² de área verde por habitante recomienda la OMS?',
        options: ['3 m²', '6 m²', '9 m²', '15 m²'],
        correctIndex: 2,
      ),
      QuizQuestion(
        question: '¿Qué mide el índice IARRI-MX?',
        options: [
          'La calidad del aire',
          'El riesgo metabólico del entorno urbano',
          'La temperatura promedio',
          'El tráfico vehicular',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        question: '¿Cuál de estos factores NO forma parte del IARRI-MX?',
        options: [
          'Acceso a áreas verdes',
          'Equipamiento deportivo',
          'Número de hospitales',
          'Entorno alimentario',
        ],
        correctIndex: 2,
      ),
    ],
  ),

  // Lección 2 — Arquitectura Preventiva
  Lesson(
    id: 2,
    title: 'Arquitectura Preventiva',
    emoji: '🏛️',
    colorValue: _low,
    sections: [
      LessonSection(
        title: '¿Qué es la arquitectura preventiva?',
        content:
            'Es el diseño del espacio construido para promover hábitos saludables. Va desde el diseño de una vivienda hasta la planificación urbana de una ciudad.',
      ),
      LessonSection(
        title: 'Diseño que invita al movimiento',
        content:
            'Escaleras visibles y accesibles, pasillos amplios, patios activos y rutas peatonales seguras aumentan la actividad física sin que la persona lo note.',
      ),
      LessonSection(
        title: 'Ventilación y luz natural',
        content:
            'Espacios bien ventilados y con luz natural reducen el estrés y mejoran el sueño, dos factores clave en la prevención de resistencia a la insulina.',
      ),
      LessonSection(
        title: 'Microhuertos urbanos',
        content:
            'Los microhuertos en azoteas, patios o espacios comunitarios mejoran el acceso a vegetales frescos. Son una intervención de bajo costo y alto impacto metabólico.',
      ),
    ],
    quiz: [
      QuizQuestion(
        question: '¿Cuál es el objetivo principal de la arquitectura preventiva?',
        options: [
          'Construir hospitales',
          'Diseñar espacios que promuevan hábitos saludables',
          'Reducir costos de construcción',
          'Aumentar la densidad de vivienda',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        question:
            '¿Qué elemento arquitectónico simple aumenta la actividad física?',
        options: [
          'Elevadores modernos',
          'Escaleras visibles y accesibles',
          'Estacionamientos amplios',
          'Ventanas pequeñas',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        question:
            '¿Cómo ayuda la luz natural a prevenir la resistencia a la insulina?',
        options: [
          'Quema calorías directamente',
          'Reduce el estrés y mejora el sueño',
          'Aumenta la producción de insulina',
          'No tiene relación',
        ],
        correctIndex: 1,
      ),
    ],
  ),

  // Lección 3 — Alimentación Saludable (quiz no-multiple → lista vacía)
  Lesson(
    id: 3,
    title: 'Alimentación Saludable',
    emoji: '🥗',
    colorValue: _low,
    sections: [
      LessonSection(
        title: '¿Qué comemos y cómo nos afecta?',
        content:
            'La alimentación es uno de los factores más importantes en la resistencia a la insulina. Los alimentos ultraprocesados, ricos en azúcares simples y grasas trans, elevan rápidamente la glucosa en sangre.',
      ),
      LessonSection(
        title: 'El plato del buen comer',
        content:
            'Una alimentación saludable incluye: 50% verduras y frutas, 25% cereales integrales y 25% proteínas de calidad. Limitar azúcares, harinas refinadas y bebidas azucaradas es clave.',
      ),
      LessonSection(
        title: 'Índice glucémico',
        content:
            'Los alimentos con alto índice glucémico (pan blanco, refresco, papas fritas) elevan rápidamente el azúcar en sangre. Los de bajo índice (avena, legumbres, verduras) la elevan lentamente, protegiendo al páncreas.',
      ),
    ],
    quiz: [], // tipo ordena_plato — no soportado en esta versión
  ),

  // Lección 4 — Actividad Física Preventiva (quiz verdadero_falso → lista vacía)
  Lesson(
    id: 4,
    title: 'Actividad Física Preventiva',
    emoji: '🏃',
    colorValue: _accent,
    sections: [
      LessonSection(
        title: '¿Por qué moverse previene la resistencia?',
        content:
            'El músculo en movimiento consume glucosa sin necesitar insulina. 30 minutos de caminata diaria pueden reducir el riesgo de diabetes tipo 2 hasta en un 30%.',
      ),
      LessonSection(
        title: 'Tipos de ejercicio recomendados',
        content:
            'El ejercicio aeróbico (caminar, nadar, bicicleta) mejora la sensibilidad a la insulina. El ejercicio de fuerza aumenta la masa muscular que consume glucosa. La combinación es ideal.',
      ),
      LessonSection(
        title: 'Barreras arquitectónicas',
        content:
            'La falta de banquetas seguras, parques y ciclovías en colonias de Puebla reduce la actividad física involuntaria. El entorno construido puede ser aliado o enemigo de tu salud metabólica.',
      ),
    ],
    quiz: [], // tipo verdadero_falso — no soportado en esta versión
  ),

  // Lección 5 — Estrés, Sueño y Metabolismo (quiz sopa_letras → lista vacía)
  Lesson(
    id: 5,
    title: 'Estrés, Sueño y Metabolismo',
    emoji: '😴',
    colorValue: _accent3,
    sections: [
      LessonSection(
        title: 'El estrés eleva el azúcar en sangre',
        content:
            'Cuando estás estresado, tu cuerpo libera cortisol. Esta hormona eleva la glucosa en sangre. Si el estrés es crónico, el páncreas trabaja en exceso y puede desarrollarse resistencia a la insulina.',
      ),
      LessonSection(
        title: 'Dormir poco empeora la insulina',
        content:
            'Dormir menos de 6 horas aumenta la resistencia a la insulina en solo una semana. Durante el sueño, el cuerpo regula hormonas metabólicas clave como la leptina, grelina e insulina.',
      ),
      LessonSection(
        title: 'Diseño del espacio para reducir estrés',
        content:
            'Espacios con luz natural, ventilación cruzada y acceso a áreas verdes reducen el cortisol. La arquitectura puede ser una intervención directa contra el estrés crónico.',
      ),
    ],
    quiz: [], // tipo sopa_letras — no soportado en esta versión
  ),

  // Lección 6 — Puebla y sus Datos IARRI (quiz relaciona → lista vacía)
  Lesson(
    id: 6,
    title: 'Puebla y sus Datos IARRI',
    emoji: '🗺️',
    colorValue: _mid,
    sections: [
      LessonSection(
        title: 'Tres municipios, tres realidades',
        content:
            'San Andrés Cholula, San Pablo Xochimehuacan y Cuautlancingo tienen índices IARRI muy diferentes. Sus condiciones de áreas verdes, caminabilidad y entorno alimentario varían significativamente.',
      ),
      LessonSection(
        title: '¿Qué dicen los datos?',
        content:
            'San Andrés Cholula tiene el mejor acceso a áreas verdes (AV=0.80). Cuautlancingo tiene el mayor índice de entorno alimentario riesgoso (EAR=0.80), con alta densidad de tiendas de ultraprocesados.',
      ),
      LessonSection(
        title: 'Intervención prioritaria',
        content:
            'Cuautlancingo requiere intervención urgente: incrementar áreas verdes, mejorar caminabilidad y fomentar equipamiento deportivo reduciría su IARRI de 0.78 a 0.64 (-18.2%).',
      ),
    ],
    quiz: [], // tipo relaciona — no soportado en esta versión
  ),
];

// ─── MICROCURSOS ──────────────────────────────────────────────────────────────

const List<Microcourse> microcourses = [
  // Microcurso 1: ¿Qué es la Resistencia a la Insulina?
  Microcourse(
    id: 'mc_ri',
    title: '¿Qué es la Resistencia a la Insulina?',
    description:
        'Descubre cómo funciona la insulina, por qué el cuerpo puede volverse resistente y qué señales debes identificar.',
    emoji: '🔬',
    colorValue: _accent,
    levelName: 'Fundamentos',
    totalXp: 150,
    badgeEmoji: '🧬',
    badgeName: 'Experto en Insulina',
    lessonIds: [0],
    evalTitle: 'Evaluación: Resistencia a la Insulina',
    evalDescription:
        'Demuestra lo que aprendiste sobre la hormona que controla tu energía.',
    evalQuestions: [
      EvalQuestion(
        question: '¿Cuál es la función principal de la insulina en el cuerpo?',
        options: [
          'Descomponer las grasas en el hígado',
          'Permitir que la glucosa entre a las células para producir energía',
          'Regular la presión arterial',
          'Producir glóbulos rojos',
        ],
        correctIndex: 1,
        explanation:
            'La insulina es la "llave" que abre las células para que la glucosa pueda entrar y convertirse en energía.',
        xp: 30,
      ),
      EvalQuestion(
        question:
            '¿Qué ocurre cuando las células se vuelven resistentes a la insulina?',
        options: [
          'El páncreas produce menos insulina inmediatamente',
          'El cuerpo quema más grasa automáticamente',
          'El páncreas produce más insulina para compensar la resistencia',
          'La glucosa se elimina por la orina sin consecuencias',
        ],
        correctIndex: 2,
        explanation:
            'El páncreas trabaja en exceso tratando de vencer la resistencia. Con el tiempo se agota, lo que puede llevar a diabetes tipo 2.',
        xp: 30,
      ),
      EvalQuestion(
        question:
            '¿Cuál es la señal de alerta cutánea de la resistencia a la insulina?',
        options: [
          'Manchas rojas en brazos',
          'Piel escamosa en manos',
          'Piel oscura en cuello o axilas (acantosis nigricans)',
          'Uñas amarillas',
        ],
        correctIndex: 2,
        explanation:
            'La acantosis nigricans es una hiperpigmentación en pliegues de la piel directamente asociada a la hiperinsulinemia.',
        xp: 30,
      ),
      EvalQuestion(
        question:
            '¿Qué porcentaje de adultos mexicanos tiene resistencia a la insulina?',
        options: ['5%', '15%', '30%', '50%'],
        correctIndex: 2,
        explanation:
            'Más del 30% de la población adulta en México tiene algún grado de RI, muchas veces sin síntomas evidentes.',
        xp: 30,
      ),
      EvalQuestion(
        question:
            '¿Cuál de estos NO es un síntoma típico de resistencia a la insulina?',
        options: [
          'Cansancio intenso después de comer',
          'Antojos frecuentes de azúcar',
          'Dificultad para bajar de peso en el abdomen',
          'Visión doble constante',
        ],
        correctIndex: 3,
        explanation:
            'La visión doble no es característica de la RI. Los síntomas clásicos son fatiga postprandial, antojos y adiposidad abdominal.',
        xp: 30,
      ),
    ],
  ),

  // Microcurso 2: Entorno Construido y Salud Metabólica
  Microcourse(
    id: 'mc_entorno',
    title: 'Entorno Construido y Salud Metabólica',
    description:
        'Entiende cómo el diseño de tu ciudad, tus calles y tu barrio influyen directamente en el riesgo de resistencia a la insulina.',
    emoji: '🏙️',
    colorValue: _accent3,
    levelName: 'Territorio y Salud',
    totalXp: 200,
    badgeEmoji: '🗺️',
    badgeName: 'Urbanista Metabólico',
    lessonIds: [1, 6],
    evalTitle: 'Evaluación: Entorno y Metabolismo',
    evalDescription:
        'Ponemos a prueba tu comprensión del vínculo entre ciudad y salud.',
    evalQuestions: [
      EvalQuestion(
        question:
            '¿Cuántos m² de área verde por habitante recomienda la OMS?',
        options: ['3 m²', '6 m²', '9 m²', '12 m²'],
        correctIndex: 2,
        explanation:
            'La OMS establece 9 m² por habitante como estándar mínimo para promover la actividad física espontánea y el bienestar.',
        xp: 40,
      ),
      EvalQuestion(
        question:
            '¿Cuál municipio de Puebla tiene el mayor entorno alimentario riesgoso (EAR)?',
        options: [
          'San Andrés Cholula',
          'San Pablo Xochimehuacan',
          'Cuautlancingo',
          'Puebla Centro',
        ],
        correctIndex: 2,
        explanation:
            'Cuautlancingo tiene EAR=0.80, con alta densidad de tiendas de ultraprocesados, lo que eleva el riesgo metabólico de sus habitantes.',
        xp: 40,
      ),
      EvalQuestion(
        question: '¿Qué mide el Índice IARRI-MX?',
        options: [
          'La calidad del aire urbano',
          'El riesgo metabólico del entorno construido',
          'La densidad de hospitales por municipio',
          'El nivel socioeconómico promedio',
        ],
        correctIndex: 1,
        explanation:
            'IARRI-MX combina 5 variables: áreas verdes, caminabilidad, equipamiento deportivo, entorno alimentario e índice de marginación.',
        xp: 40,
      ),
      EvalQuestion(
        question:
            '¿Cuál de estas variables del IARRI-MX es "inversa" (mayor valor = menor riesgo)?',
        options: [
          'EAR - Entorno Alimentario Riesgoso',
          'IMP - Índice de Marginación',
          'AV - Áreas Verdes',
          'Ninguna de las anteriores',
        ],
        correctIndex: 2,
        explanation:
            'AV, IC y ED son inversas: más áreas verdes, caminabilidad y equipamiento deportivo = menor riesgo. EAR e IMP son directas.',
        xp: 40,
      ),
      EvalQuestion(
        question: '¿Qué tipo de diseño urbano promueve el sedentarismo?',
        options: [
          'Ciudades con ciclovías y banquetas amplias',
          'Barrios con plazas y parques accesibles',
          'Ciudades diseñadas para el automóvil, sin áreas peatonales',
          'Colonias con equipamiento deportivo público',
        ],
        correctIndex: 2,
        explanation:
            'El urban sprawl centrado en el auto elimina la actividad física cotidiana (caminar al trabajo, a la tienda, etc.), aumentando el riesgo metabólico.',
        xp: 40,
      ),
    ],
  ),

  // Microcurso 3: Prevención Activa
  Microcourse(
    id: 'mc_prevencion',
    title: 'Prevención Activa',
    description:
        'Aprende estrategias prácticas de arquitectura preventiva, alimentación y actividad física para reducir tu riesgo metabólico.',
    emoji: '🏃',
    colorValue: _low,
    levelName: 'Acción',
    totalXp: 250,
    badgeEmoji: '🏅',
    badgeName: 'Agente Preventivo',
    lessonIds: [2, 3, 4],
    evalTitle: 'Evaluación: Prevención Activa',
    evalDescription:
        'Demuestra que puedes aplicar lo aprendido para mejorar tu entorno y hábitos.',
    evalQuestions: [
      EvalQuestion(
        question:
            '¿Cuántos minutos de caminata diaria reducen hasta 30% el riesgo de diabetes tipo 2?',
        options: ['10 minutos', '20 minutos', '30 minutos', '60 minutos'],
        correctIndex: 2,
        explanation:
            '30 minutos de caminata diaria a ritmo moderado mejoran significativamente la sensibilidad a la insulina según múltiples estudios.',
        xp: 50,
      ),
      EvalQuestion(
        question:
            '¿Cuál es la principal razón por la que el músculo consume glucosa sin insulina?',
        options: [
          'El músculo produce su propia insulina local',
          'Durante el ejercicio, las células musculares activan transportadores GLUT4 independientes de insulina',
          'El glucógeno muscular reemplaza a la insulina',
          'La adrenalina actúa como insulina durante el ejercicio',
        ],
        correctIndex: 1,
        explanation:
            'Durante el ejercicio, la contracción muscular activa transportadores GLUT4 que permiten la entrada de glucosa SIN necesitar insulina. Por eso el ejercicio es tan poderoso.',
        xp: 50,
      ),
      EvalQuestion(
        question:
            '¿Qué alimento tiene bajo índice glucémico y protege al páncreas?',
        options: ['Pan blanco', 'Refresco de cola', 'Avena integral', 'Papas fritas'],
        correctIndex: 2,
        explanation:
            'La avena tiene bajo índice glucémico: libera glucosa lentamente, evitando picos de insulina que con el tiempo generan resistencia.',
        xp: 50,
      ),
      EvalQuestion(
        question:
            '¿Qué característica arquitectónica simple aumenta la actividad física sin esfuerzo consciente?',
        options: [
          'Elevadores rápidos y modernos',
          'Escaleras visibles, amplias y atractivas',
          'Estacionamientos grandes cerca de la entrada',
          'Pasillos cortos para minimizar recorridos',
        ],
        correctIndex: 1,
        explanation:
            'Las escaleras visibles y bien diseñadas aumentan hasta 30% su uso frente a los elevadores, sumando actividad física cotidiana sin que la persona lo "decida".',
        xp: 50,
      ),
      EvalQuestion(
        question:
            '¿Qué porcentaje del plato debe corresponder a verduras y frutas según el "plato del buen comer"?',
        options: ['25%', '35%', '50%', '75%'],
        correctIndex: 2,
        explanation:
            'El plato saludable se divide en: 50% verduras y frutas, 25% cereales integrales y 25% proteínas de calidad.',
        xp: 50,
      ),
    ],
  ),

  // Microcurso 4: Estrés, Sueño y Metabolismo
  Microcourse(
    id: 'mc_estres_sueno',
    title: 'Estrés, Sueño y Metabolismo',
    description:
        'Explora el impacto del estrés crónico y la falta de sueño en la resistencia a la insulina, y cómo el diseño del espacio puede ayudarte.',
    emoji: '😴',
    colorValue: _accent3,
    levelName: 'Factores Invisibles',
    totalXp: 150,
    badgeEmoji: '🌙',
    badgeName: 'Maestro del Descanso',
    lessonIds: [5],
    evalTitle: 'Evaluación: Estrés y Sueño',
    evalDescription:
        'Comprueba tu dominio sobre los factores metabólicos que no siempre se ven.',
    evalQuestions: [
      EvalQuestion(
        question: '¿Qué hormona del estrés eleva la glucosa en sangre?',
        options: ['Serotonina', 'Cortisol', 'Melatonina', 'Leptina'],
        correctIndex: 1,
        explanation:
            'El cortisol es la hormona del estrés. Cuando se libera crónicamente, eleva la glucosa y obliga al páncreas a producir más insulina, generando resistencia.',
        xp: 30,
      ),
      EvalQuestion(
        question:
            '¿Cuántas horas de sueño mínimo se necesitan para no aumentar la resistencia a la insulina?',
        options: ['4 horas', '6 horas', '8 horas', '10 horas'],
        correctIndex: 1,
        explanation:
            'Dormir menos de 6 horas por noche aumenta la resistencia a la insulina en tan solo una semana, según estudios clínicos controlados.',
        xp: 30,
      ),
      EvalQuestion(
        question:
            '¿Cuál elemento del diseño arquitectónico ayuda a reducir el cortisol?',
        options: [
          'Techos altos sin ventanas',
          'Pasillos angostos y oscuros',
          'Luz natural, ventilación cruzada y acceso a áreas verdes',
          'Aislamiento total del exterior',
        ],
        correctIndex: 2,
        explanation:
            'Estudios de neuroarquitectura demuestran que la luz natural, las vistas a vegetación y la ventilación reducen los niveles de cortisol y mejoran el sueño.',
        xp: 30,
      ),
      EvalQuestion(
        question:
            '¿Qué hormona regula el apetito y se desregula con la falta de sueño?',
        options: ['Insulina', 'Adrenalina', 'Grelina y leptina', 'Tiroxina'],
        correctIndex: 2,
        explanation:
            'La grelina (hormona del hambre) aumenta y la leptina (saciedad) disminuye cuando dormimos mal, generando mayor consumo calórico al día siguiente.',
        xp: 30,
      ),
      EvalQuestion(
        question:
            '¿Qué relación tiene el estrés crónico con la diabetes tipo 2?',
        options: [
          'No tiene relación directa',
          'Reduce la producción de insulina temporalmente',
          'El cortisol crónico genera resistencia a la insulina que puede derivar en diabetes tipo 2',
          'Solo afecta a personas con predisposición genética',
        ],
        correctIndex: 2,
        explanation:
            'El estrés crónico mantiene el cortisol elevado de forma permanente, lo que genera resistencia a la insulina sostenida. Es un factor de riesgo independiente para diabetes tipo 2.',
        xp: 30,
      ),
    ],
  ),
];

// ─── HELPERS ──────────────────────────────────────────────────────────────────

/// Suma todo el XP ganado en todos los microcursos.
int totalXp(Map<String, dynamic> progress) {
  int total = 0;
  for (final mc in microcourses) {
    final xp = progress['mc_${mc.id}_xp'];
    if (xp is int) total += xp;
  }
  return total;
}

/// Devuelve el nivel actual según los XP acumulados.
XpLevel currentLevel(int xp) {
  XpLevel result = xpLevels.first;
  for (final level in xpLevels) {
    if (xp >= level.xpMin) {
      result = level;
    }
  }
  return result;
}

/// Devuelve el siguiente nivel, o null si ya está en el máximo.
XpLevel? nextLevel(int xp) {
  for (final level in xpLevels) {
    if (xp < level.xpMin) return level;
  }
  return null;
}

/// Devuelve true si el microcurso fue completado (evaluación aprobada con XP > 0).
bool isMicrocourseCompleted(String mcId, Map<String, dynamic> progress) {
  final completed = progress['mc_${mcId}_evaluacion_completada'];
  return completed == true;
}

/// Cuenta cuántas lecciones del microcurso fueron completadas.
int microcourseProgress(Microcourse mc, Map<String, dynamic> progress) {
  int count = 0;
  for (final lessonId in mc.lessonIds) {
    final done = progress['leccion_${lessonId}_completada'];
    if (done == true) count++;
  }
  return count;
}

/// Obtiene una lección por ID.
Lesson? lessonById(int id) {
  for (final lesson in lessons) {
    if (lesson.id == id) return lesson;
  }
  return null;
}
