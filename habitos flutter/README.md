# HabitosApp (Flutter)

ACT02 · Disseny d'interfícies y persistencia local · DAM2

## Cómo ejecutarlo

```bash
flutter pub get
flutter run
```

En Android Studio, abre la carpeta `habitos flutter` y ejecuta `lib/main.dart`.
Es el único punto de entrada de la aplicación. La cuenta de administración
inicial es `admin` / `admin`.

El acceso normal permite crear una cuenta y gestionar hábitos propios. El panel
de administración permite gestionar las cuentas, los hábitos y las estadísticas
globales. Para conocer las pantallas y los componentes reutilizables, consulta
[README_ACT02.md](./README_ACT02.md).

## Estructura

```
lib/
├── main.dart
├── models/                 # Hábitos y usuarios
├── services/               # Persistencia local
├── screens/                # Acceso, registro, hábitos, estadísticas y administración
└── widgets/                # CampoTextoApp, BotonPrincipal, TarjetaHabito y DatoEstadistica
```

La autenticación local es solo para la actividad: `SharedPreferences` no protege
las contraseñas ni sustituye un servicio de autenticación de producción.
