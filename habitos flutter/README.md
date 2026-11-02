# HabitosApp (Flutter)

ACT02 · Persistencia de datos (I) · DAM2 – Accés a dades

## Cómo ejecutarlo

```bash
flutter create --project-name habitos_app .   # genera android/, ios/, web/... (no sobrescribe lib/ ni pubspec.yaml si eliges mantenerlos)
flutter pub get
flutter run
```

> Si partes de cero: `flutter create habitos_app`, copia `lib/` y `pubspec.yaml`, y ejecuta
> `flutter pub add shared_preferences` y `flutter pub add intl`.

## Actividad Diseño de Interfaces (Pantallas y navegación)

Mismo proyecto, punto de entrada propio con datos en memoria:

```bash
flutter run -t lib/main_interfaces.dart
```

- `screens/inicio_screen.dart` → Bienvenida (nombre + objetivo, botón Comenzar → push con datos al constructor)
- `screens/ficha_principal_screen.dart` → Saludo, objetivo y ficha del hábito "Beber agua" + Editar hábito + marcar/desmarcar
- `screens/editar_habito_screen.dart` → TextField con el nombre, 3 colores en una Row (Azul/Verde/Naranja), Guardar (`pop(context, resultado)`) y Cancelar / flecha (`pop` → null)
- `models/habito_ejemplo.dart` → modelo en memoria

## Estructura

```
lib/
├── main.dart                         # Arranque, carga asíncrona, tema y tamaño de letra
├── models/habito.dart                # Clase Habito con toJson()/fromJson()
├── services/preferencias_service.dart# ÚNICO acceso a SharedPreferences + claves constantes
├── screens/
│   ├── bienvenida_screen.dart        # Solo la primera vez (nombre + objetivo)
│   ├── home_shell.dart               # Navegación inferior (Hoy / Estadísticas / Ajustes)
│   ├── principal_screen.dart         # Saludo, progreso y lista con casillas
│   ├── habito_form_screen.dart       # Crear / editar / borrar hábito
│   ├── estadisticas_screen.dart      # StatelessWidget: rachas, totales, aperturas
│   └── ajustes_screen.dart           # Tema, tamaño de letra, ocultar completados, borrar datos
└── widgets/
    ├── habito_tile.dart
    ├── progreso_card.dart
    ├── stat_card.dart
    └── selector_color.dart
```

## Los 5 tipos de shared_preferences

| Tipo          | Clave                  | Uso                               |
|---------------|------------------------|-----------------------------------|
| String        | `nombre_usuario`, `ultima_apertura` | nombre, fecha/hora ISO   |
| int           | `objetivo_diario`, `contador_aperturas` | objetivo, nº aperturas |
| bool          | `onboarding_hecho`, `tema_oscuro`, `ocultar_completados` | flags |
| double        | `tamano_letra`         | factor de escala del texto        |
| List<String>  | `habitos`              | cada hábito serializado con jsonEncode |

## StatelessWidget vs StatefulWidget

- **StatelessWidget**: no tiene estado mutable propio; se redibuja solo cuando su padre
  le pasa datos nuevos (`EstadisticasScreen`, `HabitoTile`, `ProgresoCard`, `StatCard`).
- **StatefulWidget**: tiene un objeto `State` y usa `setState()` para redibujarse cuando
  cambian sus datos (`HabitosApp`, `BienvenidaScreen`, `PrincipalScreen`, `AjustesScreen`...).

> En navegador (`flutter run -d chrome`) "abrir la app" equivale a **refrescar** la página.
