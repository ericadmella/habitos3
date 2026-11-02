import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitos_app/main.dart';
import 'package:habitos_app/models/habito.dart';
import 'package:habitos_app/services/preferencias_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferenciasService.instance.init();
  });

  testWidgets('registers an account and creates a personal habit',
      (tester) async {
    await tester.pumpWidget(const HabitosApp());
    expect(find.text('Iniciar sesión'), findsOneWidget);

    await tester.tap(find.text('Crear una cuenta'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Ana Pérez');
    await tester.enterText(find.byType(TextFormField).at(1), 'ana');
    await tester.enterText(find.byType(TextFormField).at(2), 'clave');
    await tester.tap(find.text('Registrarse'));
    await tester.pumpAndSettle();

    final cuenta = PreferenciasService.instance
        .cargarUsuarios()
        .singleWhere((usuario) => usuario.nombreUsuario == 'ana');
    expect(cuenta.fechaCreacion, isNotNull);

    await tester.enterText(find.byType(TextFormField).at(0), 'ana');
    await tester.enterText(find.byType(TextFormField).at(1), 'clave');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Todavía no tienes hábitos'), findsOneWidget);

    await tester.tap(find.byTooltip('Crear hábito'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Leer');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Leer'), findsOneWidget);

    await tester.tap(find.text('Estadísticas'));
    await tester.pumpAndSettle();
    expect(find.text('Racha actual'), findsOneWidget);
    expect(find.text('Días completados'), findsOneWidget);
  });

  testWidgets('shows the administration panel only to the admin account',
      (tester) async {
    await tester.pumpWidget(const HabitosApp());
    await tester.enterText(find.byType(TextFormField).at(0), 'admin');
    await tester.enterText(find.byType(TextFormField).at(1), 'admin');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Gestión de usuarios'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.checklist));
    await tester.pumpAndSettle();
    expect(find.text('Gestión de hábitos'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.bar_chart));
    await tester.pumpAndSettle();
    expect(find.text('Estadísticas globales'), findsOneWidget);
  });

  testWidgets('each account sees only its own habits', (tester) async {
    final servicio = PreferenciasService.instance;
    final ana = await servicio.registrarUsuario(
      nombre: 'Ana',
      nombreUsuario: 'ana',
      contrasena: 'clave',
    );
    final luis = await servicio.registrarUsuario(
      nombre: 'Luis',
      nombreUsuario: 'luis',
      contrasena: 'clave',
    );
    await servicio.guardarHabito(
      Habito(
          id: 'ana-habito',
          usuarioId: ana.id,
          nombre: 'Lectura',
          color: 0xFFFF6B6B),
    );
    await servicio.guardarHabito(
      Habito(
          id: 'luis-habito',
          usuarioId: luis.id,
          nombre: 'Ejercicio',
          color: 0xFF1DD1A1),
    );
    expect(servicio.autenticar('ana', 'clave')?.id, ana.id);

    await tester.pumpWidget(const HabitosApp());
    await tester.enterText(find.byType(TextFormField).at(0), 'ana');
    await tester.enterText(find.byType(TextFormField).at(1), 'clave');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Mis hábitos'), findsOneWidget);
    expect(find.text('Lectura'), findsOneWidget);
    expect(find.text('Ejercicio'), findsNothing);
  });
}
