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
- `registro_page.dart`: guarda nombre, apellidos, correo, usuario, contraseña,
  rol y fecha de creación.
- `habitos_page.dart`: lista los hábitos propios, permite crearlos, editarlos,
  eliminarlos, marcarlos como completados, consultar estadísticas y cerrar sesión.
- `editar_habito_page.dart`: abre el mismo formulario para crear y editar.
- `estadisticas_page.dart`: muestra la racha y los días completados de cada hábito.
- `administracion_page.dart`: permite al administrador gestionar usuarios y
  hábitos y consultar estadísticas globales. Al entrar, muestra un panel con
  accesos directos a usuarios, hábitos, estadísticas y ajustes.

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
- `lib/servicios/base_datos_local.dart`: base de datos SQLite y operaciones CRUD.
- `lib/servicios/preferencias_service.dart`: ajustes y preferencias de la app.
- `lib/pantallas/`: pantallas de usuario y administración.
- `lib/widgets/`: componentes reutilizables.

## Base de datos local

SQLite crea las tablas `usuarios`, `habitos` y `estadisticas`. Las fechas
completadas de cada hábito se guardan como JSON dentro de su registro, y la
tabla de estadísticas mantiene la racha actual y los días completados.
El administrador puede editar esas fechas desde la gestión de hábitos; las
estadísticas se recalculan al guardar y se eliminan al borrar el hábito asociado.
`SharedPreferences` se reserva para los ajustes y preferencias de la aplicación.
Los datos de usuarios y hábitos de versiones anteriores se migran al primer
inicio con SQLite.

La autenticación es local para esta actividad; las contraseñas se guardan sin
cifrar y no debe usarse con datos reales en producción.
