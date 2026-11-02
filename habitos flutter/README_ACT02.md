# HábitosApp — ACT02 Interfaces y componentes

## Ejecutar
- La aplicación se inicia siempre desde `lib/main.dart` (`flutter run`).
- Este proyecto tiene un único punto de entrada para Android Studio.

## Componentes reutilizables añadidos
- `lib/widgets/campo_texto_app.dart`: campo de texto con etiqueta, controlador y opción `ocultar`.
- `lib/widgets/boton_principal.dart`: botón con estilo común y callback `onPressed`.
- `lib/widgets/tarjeta_habito.dart`: tarjeta con nombre, color, estado y callbacks para completar, editar y eliminar.
- `lib/widgets/dato_estadistica.dart`: dato estadístico con etiqueta, valor, icono y color.

Los componentes están disponibles en `lib/widgets/`. Las pantallas de demostración de login, registro y administración no son puntos de entrada independientes de la aplicación.

## Importante: límites de esta entrega
El proyecto utiliza `SharedPreferences` para guardar preferencias y hábitos locales, pero no contiene un modelo/servicio de cuentas de usuario ni roles persistidos. Las pantallas de login y registro son una maqueta de navegación: `admin/admin` abre el panel de administración, el registro valida campos pero no crea una cuenta persistente y las opciones de administración indican que falta conectar el servicio. No debe presentarse como autenticación segura ni como gestión real multiusuario. Para cumplir esa parte de forma funcional, hay que integrar el modelo y persistencia de usuarios de la actividad de Acceso a Datos.

## Estructura
- `lib/main.dart`: entrada original y configuración global.
- `lib/screens/`: pantallas.
- `lib/widgets/`: componentes reutilizables.
- `lib/models/`: modelos de datos.
- `lib/services/`: persistencia local.
