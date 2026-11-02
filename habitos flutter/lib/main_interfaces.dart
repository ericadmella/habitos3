import 'package:flutter/material.dart';

import 'screens/inicio_screen.dart';

/// ACTIVIDAD DISEÑO DE INTERFACES – Pantallas y navegación.
///
/// Punto de entrada alternativo del MISMO proyecto. Ejecuta con:
///   flutter run -t lib/main_interfaces.dart
///
/// Aquí los datos están en memoria (sin shared_preferences); la versión con
/// persistencia completa es lib/main.dart (actividad de Acceso a Datos).
void main() {
  runApp(const HabitosInterfacesApp());
}

/// Único MaterialApp de esta versión.
class HabitosInterfacesApp extends StatelessWidget {
  const HabitosInterfacesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitosApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFFF7F50),
        useMaterial3: true,
      ),
      home: const InicioScreen(),
    );
  }
}
