# HábitosApp — ACT02 Disseny d'interfícies

## Ejecutar

Abre la carpeta `habitos flutter` en Android Studio y ejecuta `lib/main.dart`,
o usa:

```bash
flutter pub get
flutter run
```

La aplicación tiene un solo punto de entrada. La cuenta local inicial de
administración es `admin` / `admin`.

## Flujo y pantallas

- `login_page.dart`: acceso de usuarios y administrador; enlaza con el registro.
- `registro_page.dart`: guarda nombre, usuario, contraseña y fecha de creación.
- `habitos_page.dart`: lista los hábitos propios, permite crearlos, editarlos,
  eliminarlos, marcarlos como completados, consultar estadísticas y cerrar sesión.
- `editar_habito_page.dart`: abre el mismo formulario para crear y editar.
- `estadisticas_page.dart`: muestra la racha y los días completados de cada hábito.
- `administracion_page.dart`: permite al administrador gestionar usuarios y
  hábitos y consultar estadísticas globales.

Las cuentas nuevas solo pueden consultar y modificar sus propios hábitos. El
administrador puede gestionar las cuentas y los hábitos de la aplicación.

## Componentes reutilizables

Los cuatro componentes son `StatelessWidget` y reciben los datos y las acciones
por constructor:

- `CampoTextoApp`: etiqueta, controlador, opción para ocultar contraseña y
  validación. Se usa en acceso, registro y formularios de hábitos.
- `BotonPrincipal`: texto y acción del botón. Se comparte entre acceso, registro,
  formularios y administración.
- `TarjetaHabito`: nombre, color, estado e icono opcional; sus acciones completan,
  editan y eliminan el hábito indicado.
- `DatoEstadistica`: etiqueta, valor, icono y color opcional; se usa en estadísticas
  individuales y globales.

Los estilos comunes están centralizados en `lib/widgets/`; por eso un cambio en
uno de estos widgets se refleja en todas las pantallas donde se reutiliza.

## Carpetas principales

- `lib/main.dart`: inicialización y navegación según el usuario autenticado.
- `lib/models/`: modelos de hábitos y usuarios.
- `lib/services/preferencias_service.dart`: persistencia local.
- `lib/screens/`: pantallas de usuario y administración.
- `lib/widgets/`: componentes reutilizables.

## Nota sobre el acceso

La autenticación y los datos se guardan localmente con `SharedPreferences` para
esta actividad. No es un sistema de autenticación seguro ni una solución para
publicar con datos reales: las contraseñas y roles necesitan un servicio de
autenticación y almacenamiento seguro en una aplicación de producción.
