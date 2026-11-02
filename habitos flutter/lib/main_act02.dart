import 'package:flutter/material.dart';
import 'screens/login_page.dart';

/// Punto de entrada de demostración para ACT02. Ejecutar: flutter run -t lib/main_act02.dart
void main() => runApp(const HabitosAct02App());
class HabitosAct02App extends StatelessWidget {
  const HabitosAct02App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'HábitosApp - ACT02', debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: const Color(0xFFFF7F50), useMaterial3: true),
    home: const LoginPage(),
  );
}
