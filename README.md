# ARQ-Metabólica MX 🏙️🧪

**ARQ-Metabólica MX** es una plataforma interactiva diseñada para analizar y mejorar el entorno urbano con el fin de prevenir la resistencia a la insulina. Basada en una arquitectura limpia y principios de gamificación, la app permite a los usuarios diagnosticar su territorio, calcular riesgos metabólicos y aprender estrategias de intervención arquitectónica.

## 🚀 Características Principales

- **Calculadora IARRI & IARM**: Diagnóstico individual y territorial mediante lógica difusa y simulaciones de Monte Carlo.
- **Mapa Territorial Interactivo**: Visualización detallada de variables urbanas en municipios de Puebla y análisis por colonias.
- **Intervención & Recomendaciones**: Estrategias de "Arquitectura Preventiva" personalizadas según el nivel de riesgo.
- **Gamificación**: Sistema de niveles, XP e insignias basadas en el progreso del usuario y retos semanales.
- **Educación Interactiva**: Microcursos y lecciones sobre diseño urbano y salud metabólica.
- **Autenticación Segura**: Gestión de sesiones y perfiles integrada con Supabase.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **Gestión de Estado**: [Riverpod](https://riverpod.dev/)
- **Navegación**: [GoRouter](https://pub.dev/packages/go_router)
- **Backend/Auth**: [Supabase](https://supabase.com/)
- **Diseño**: Clean Architecture (Feature-first approach)
- **Mapas**: [Flutter Map](https://pub.dev/packages/flutter_map) + OpenStreetMap

## 📋 Requisitos Previos

Antes de ejecutar el proyecto, asegúrate de tener instalado:

1.  **Flutter SDK**: Versión 3.24.0 o superior ([Instrucciones de instalación](https://docs.flutter.dev/get-started/install)).
2.  **Dart SDK**: Versión 3.5.0 o superior.
3.  **Android Studio / VS Code**: Con las extensiones de Flutter y Dart instaladas.
4.  **Supabase Project**: Necesitas una instancia activa de Supabase para el backend.

## ⚙️ Configuración y Ejecución

Sigue estos pasos para poner en marcha el proyecto localmente:

### 1. Clonar el repositorio
```bash
git clone https://github.com/tu-usuario/metabolica-mx.git
cd metabolica-mx
```

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Configurar variables de entorno
Crea un archivo en `lib/config/env.dart` (si no existe) y configura tus credenciales de Supabase:

```dart
class Env {
  static const String supabaseUrl = 'TU_SUPABASE_URL';
  static const String supabaseAnonKey = 'TU_SUPABASE_ANON_KEY';
}
```

*Nota: Asegúrate de que `env.dart` esté en tu `.gitignore` para no exponer llaves privadas.*

### 4. Ejecutar la aplicación
Para iniciar la app en un emulador o dispositivo físico:

```bash
flutter run
```

### 5. Análisis y Pruebas
Para verificar la integridad del código:

```bash
flutter analyze  # Verifica errores de tipado y estilo
flutter test     # Ejecuta las pruebas unitarias y de widget
```

---
Desarrollado con ❤️ para mejorar la salud urbana en México.
