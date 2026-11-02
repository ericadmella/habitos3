# HábitosApp — ACT02 Interfaces y componentes

## Ejecutar
- Versión original de la aplicación: `flutter run -t lib/main.dart`
- Flujo de pantallas ACT02 (inicio de sesión): `flutter run -t lib/main_act02.dart`

## Componentes reutilizables añadidos
- `lib/widgets/campo_texto_app.dart`: campo de texto con etiqueta, controlador y opción `ocultar`.
- `lib/widgets/boton_principal.dart`: botón con estilo común y callback `onPressed`.
- `lib/widgets/tarjeta_habito.dart`: tarjeta con nombre, color, estado y callbacks para completar, editar y eliminar.
- `lib/widgets/dato_estadistica.dart`: dato estadístico con etiqueta, valor, icono y color.

Los componentes están integrados en las pantallas existentes: bienvenida, formulario de hábito, lista de hábitos y estadísticas. `lib/main_act02.dart` es una entrada alternativa para mostrar login, registro y administración.

## Importante: límites de esta entrega
El proyecto original utiliza `SharedPreferences` para guardar preferencias y hábitos locales, pero no contiene un modelo/servicio de cuentas de usuario ni roles persistidos. Por eso el login y registro de `main_act02.dart` son una maqueta de navegación: `admin/admin` abre el panel de administración, el registro valida campos pero no crea una cuenta persistente y las opciones de administración indican que falta conectar el servicio. No debe presentarse como autenticación segura ni como gestión real multiusuario. Para cumplir esa parte de forma funcional, hay que integrar el modelo y persistencia de usuarios de la actividad de Acceso a Datos.

## Estructura
- `lib/main.dart`: entrada original y configuración global.
- `lib/main_act02.dart`: entrada alternativa de demostración de ACT02.
- `lib/screens/`: pantallas.
- `lib/widgets/`: componentes reutilizables.
- `lib/models/`: modelos de datos.
- `lib/services/`: persistencia local.
