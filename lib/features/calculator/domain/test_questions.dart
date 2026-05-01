class Question {
  final String text;
  final String category;
  final String yesResponse;
  final String noResponse;

  const Question({
    required this.text,
    required this.category,
    required this.yesResponse,
    required this.noResponse,
  });
}

const List<Question> testQuestions = [
  // Síntomas físicos
  Question(
    text: "¿Sientes cansancio frecuente después de comer?",
    category: "Síntomas físicos",
    yesResponse: "Sí, me pasa seguido",
    noResponse: "No, me siento bien",
  ),
  Question(
    text: "¿Tienes antojos intensos de azúcar o carbohidratos?",
    category: "Síntomas físicos",
    yesResponse: "Sí, son muy intensos",
    noResponse: "No los tengo",
  ),
  Question(
    text: "¿Te cuesta bajar de peso, especialmente en abdomen?",
    category: "Síntomas físicos",
    yesResponse: "Sí, es muy difícil",
    noResponse: "No tengo ese problema",
  ),
  Question(
    text: "¿Presentas grasa abdominal (tipo 'panza')?",
    category: "Síntomas físicos",
    yesResponse: "Sí la presento",
    noResponse: "No la presento",
  ),
  Question(
    text: "¿Tienes piel oscura en cuello/axilas (acantosis)?",
    category: "Síntomas físicos",
    yesResponse: "Sí la tengo",
    noResponse: "No la tengo",
  ),
  Question(
    text: "¿Sientes hambre constante aunque hayas comido?",
    category: "Síntomas físicos",
    yesResponse: "Sí, siempre tengo hambre",
    noResponse: "No, como normal",
  ),
  // Indicadores metabólicos
  Question(
    text: "¿Tienes triglicéridos altos?",
    category: "Indicadores metabólicos",
    yesResponse: "Sí me lo han dicho",
    noResponse: "No o no lo sé",
  ),
  Question(
    text: "¿Tienes colesterol HDL bajo ('colesterol bueno')?",
    category: "Indicadores metabólicos",
    yesResponse: "Sí me lo han dicho",
    noResponse: "No o no lo sé",
  ),
  Question(
    text: "¿Te han dicho que tienes glucosa ligeramente elevada?",
    category: "Indicadores metabólicos",
    yesResponse: "Sí me lo han dicho",
    noResponse: "No, o no lo sé",
  ),
  Question(
    text: "¿Tienes presión arterial elevada?",
    category: "Indicadores metabólicos",
    yesResponse: "Sí la tengo alta",
    noResponse: "No, o no lo sé",
  ),
  // Estilo de vida
  Question(
    text: "¿Haces poco o nada de ejercicio?",
    category: "Estilo de vida",
    yesResponse: "Hago muy poco o nada",
    noResponse: "Hago ejercicio regular",
  ),
  Question(
    text: "¿Consumes bebidas azucaradas frecuentemente?",
    category: "Estilo de vida",
    yesResponse: "Sí, casi a diario",
    noResponse: "Casi no las tomo",
  ),
  Question(
    text: "¿Duermes menos de 6–7 horas regularmente?",
    category: "Estilo de vida",
    yesResponse: "Sí, duermo poco",
    noResponse: "Duermo bien",
  ),
  Question(
    text: "¿Tienes estrés constante?",
    category: "Estilo de vida",
    yesResponse: "Sí, todo el tiempo",
    noResponse: "No, estoy tranquilo/a",
  ),
];
