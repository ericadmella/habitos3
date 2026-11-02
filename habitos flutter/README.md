# HabitosApp (Flutter)

ACT02 · Disseny d'interfícies, SQLite y persistencia local · DAM2

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
├── servicios/              # SQLite y preferencias de configuración
├── pantallas/              # Acceso, registro, hábitos, estadísticas y administración
└── widgets/                # CampoTextoApp, BotonPrincipal, TarjetaHabito y DatoEstadistica
```

Los usuarios, hábitos y estadísticas se guardan en la base de datos SQLite
`habitos_app.db`. La configuración de tema y tamaño de letra permanece en
`SharedPreferences`. Al iniciar, las cuentas y hábitos antiguos guardados en
`SharedPreferences` se migran a SQLite.

La autenticación es local y solo para la actividad; las contraseñas se guardan
sin cifrar. No es un sistema de autenticación seguro para una aplicación de
producción.
