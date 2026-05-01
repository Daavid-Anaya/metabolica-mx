import 'dart:math';
import 'package:flutter/material.dart';

class IARRIWeights {
  static const double av = 0.20; // Áreas Verdes
  static const double ic = 0.25; // Índice de Caminabilidad
  static const double ed = 0.15; // Equipamiento Deportivo
  static const double ear = 0.25; // Entorno Alimentario Riesgoso
  static const double imp = 0.15; // Índice de Marginación
}

enum RiskLevel { low, mid, high }

class IARRILogic {
  static double calculateIARRI({
    required double av,
    required double ic,
    required double ed,
    required double ear,
    required double imp,
  }) {
    return (IARRIWeights.av * (1 - av)) +
        (IARRIWeights.ic * (1 - ic)) +
        (IARRIWeights.ed * (1 - ed)) +
        (IARRIWeights.ear * ear) +
        (IARRIWeights.imp * imp);
  }

  static double calculateProbRI(double iarri) {
    // Sigmoid function: 1 / (1 + exp(-10 * (v - 0.5)))
    return 1.0 / (1.0 + exp(-10.0 * (iarri - 0.5)));
  }

  static RiskLevel getRiskLevel(double iarri) {
    if (iarri < 0.33) return RiskLevel.low;
    if (iarri < 0.66) return RiskLevel.mid;
    return RiskLevel.high;
  }

  static String getRiskLabel(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 'Bajo';
      case RiskLevel.mid:
        return 'Medio';
      case RiskLevel.high:
        return 'Alto';
    }
  }

  static List<double> monteCarloSimulation({
    required Map<String, double> variables,
    int n = 1000,
    double sigma = 0.12,
  }) {
    final random = Random();
    final results = <double>[];

    for (var i = 0; i < n; i++) {
      final perturbed = <String, double>{};
      variables.forEach((key, value) {
        // Gaussian noise using Box-Muller transform
        final u1 = random.nextDouble();
        final u2 = random.nextDouble();
        final noise = sigma * sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);

        perturbed[key] = (value + noise).clamp(0.0, 1.0);
      });

      results.add(calculateIARRI(
        av: perturbed['AV'] ?? 0.0,
        ic: perturbed['IC'] ?? 0.0,
        ed: perturbed['ED'] ?? 0.0,
        ear: perturbed['EAR'] ?? 0.0,
        imp: perturbed['IMP'] ?? 0.0,
      ));
    }
    return results;
  }
}

class IARMLogic {
  static const double st = 0.25; // Sedentarismo Territorial
  static const double bav = 0.25; // Baja Área Verde
  static const double den = 0.25; // Alta Densidad Poblacional
  static const double bea = 0.25; // Bajo Equipamiento Activo

  static double calculateIARM({
    required double st,
    required double bav,
    required double den,
    required double bea,
  }) {
    return (st * IARMLogic.st) +
        (bav * IARMLogic.bav) +
        (den * IARMLogic.den) +
        (bea * IARMLogic.bea);
  }

  static String getRiskLabel(double iarm) {
    if (iarm < 0.33) return 'Bajo riesgo ambiental';
    if (iarm < 0.66) return 'Riesgo medio';
    return 'Alto riesgo';
  }
}

class CombinedNarrative {
  final String title;
  final String message;
  final String action;
  final Color color;
  final String icon;

  CombinedNarrative({
    required this.title,
    required this.message,
    required this.action,
    required this.color,
    required this.icon,
  });

  static CombinedNarrative get(String nivelIarri, String nivelIarm) {
    final par = [nivelIarri, nivelIarm];

    // Combinaciones críticas
    if (par[0] == 'Alto' && par[1] == 'Alto riesgo') {
      return CombinedNarrative(
        title: '⚠️ Situación crítica: doble riesgo',
        message: 'Tu riesgo individual es alto Y tu entorno construido presenta alto riesgo ambiental. La combinación amplifica significativamente la probabilidad de resistencia a la insulina.',
        action: 'Intervención urgente: considera cambiar hábitos Y presiona por mejoras urbanas en tu colonia (áreas verdes, equipamiento activo).',
        color: const Color(0xFFEF4444),
        icon: '🚨',
      );
    }
    if (par[0] == 'Alto' && par[1] == 'Riesgo medio') {
      return CombinedNarrative(
        title: '⚠️ Riesgo individual alto en entorno limitante',
        message: 'Tu riesgo personal es alto. Tu entorno tiene deficiencias moderadas que dificultan cambiar hábitos por falta de infraestructura adecuada.',
        action: 'Prioriza cambios personales mientras gestionas mejoras en el entorno inmediato (buscar parques, rutas peatonales).',
        color: const Color(0xFFEF4444),
        icon: '⚠️',
      );
    }
    if (par[0] == 'Alto' && par[1] == 'Bajo riesgo ambiental') {
      return CombinedNarrative(
        title: 'Riesgo individual alto, entorno favorable',
        message: 'Tu entorno tiene buena infraestructura activa, pero tu riesgo individual es alto. El entorno no está siendo aprovechado suficientemente.',
        action: 'Tu entorno es un aliado: úsalo. Incrementa uso de áreas verdes, rutas peatonales y equipamiento deportivo cercano.',
        color: const Color(0xFFF59E0B),
        icon: '🔶',
      );
    }
    if (par[0] == 'Medio' && par[1] == 'Alto riesgo') {
      return CombinedNarrative(
        title: 'Entorno de alto riesgo con vulnerabilidad individual media',
        message: 'Tu entorno construido presenta alto riesgo ambiental, lo que puede empeorar progresivamente tu situación metabólica individual si no se interviene.',
        action: 'El entorno es tu mayor obstáculo ahora. Busca activamente espacios activos alternativos y reduce exposición a ultraprocesados en tu zona.',
        color: const Color(0xFFF59E0B),
        icon: '🔶',
      );
    }
    if (par[0] == 'Medio' && par[1] == 'Riesgo medio') {
      return CombinedNarrative(
        title: 'Riesgo moderado en ambos frentes',
        message: 'Tanto tu situación individual como tu entorno muestran riesgo moderado. Hay margen de mejora en los dos niveles antes de que escale.',
        action: 'Momento ideal para actuar: pequeñas mejoras personales y presión por mejoras urbanas pueden reducir el riesgo significativamente.',
        color: const Color(0xFFF59E0B),
        icon: '🟡',
      );
    }
    if (par[0] == 'Medio' && par[1] == 'Bajo riesgo ambiental') {
      return CombinedNarrative(
        title: 'Buen entorno, riesgo individual a trabajar',
        message: 'Tu entorno es favorable. El riesgo proviene principalmente de factores individuales que podés mejorar con el apoyo de la infraestructura disponible.',
        action: 'Aprovechá tu entorno: establecé rutinas de actividad en los espacios disponibles cerca de vos.',
        color: const Color(0xFF22C55E),
        icon: '🟢',
      );
    }
    if (par[0] == 'Bajo' && par[1] == 'Alto riesgo') {
      return CombinedNarrative(
        title: 'Entorno de alto riesgo, bajo riesgo individual',
        message: 'Actualmente tu riesgo individual es bajo, pero vivís en un entorno de alto riesgo ambiental. Sin cambios, tu situación puede deteriorarse con el tiempo.',
        action: 'Mantené tus hábitos actuales y participá en iniciativas de mejora urbana de tu colonia. La prevención comunitaria es clave aquí.',
        color: const Color(0xFFF59E0B),
        icon: '🔔',
      );
    }
    if (par[0] == 'Bajo' && par[1] == 'Riesgo medio') {
      return CombinedNarrative(
        title: 'Situación favorable con entorno a mejorar',
        message: 'Tu riesgo individual es bajo y tu entorno tiene áreas de mejora moderadas. Estás en buena posición para mantener y mejorar.',
        action: 'Seguí con tus hábitos actuales. Explorá opciones para mejorar el entorno con tu comunidad.',
        color: const Color(0xFF22C55E),
        icon: '✅',
      );
    }
    return CombinedNarrative(
      title: '✅ Situación óptima',
      message: 'Tu riesgo individual es bajo y tu entorno construido es favorable. Estás en la mejor posición posible para mantener una salud metabólica óptima.',
      action: 'Mantené tus hábitos y aprovechá tu entorno. Compartí este resultado como referencia positiva en tu comunidad.',
      color: const Color(0xFF22C55E),
      icon: '🏆',
    );
  }
}
