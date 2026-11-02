import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitos_app/main.dart';
import 'package:habitos_app/models/habito.dart';
import 'package:habitos_app/servicios/base_datos_local.dart';
import 'package:habitos_app/servicios/preferencias_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpAfterDatabase(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferenciasService.instance.init();
    await BaseDatosLocal.instance.inicializar(enMemoria: true);
  });

  tearDown(() => BaseDatosLocal.instance.cerrar());

  testWidgets('shows the welcome screen only on the first launch',
      (tester) async {
    await tester.pumpWidget(
      const AplicacionHabitos(mostrarBienvenida: true),
    );
    expect(find.text('¡Bienvenido a HábitosApp!'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Ana');
    await tester.enterText(find.byType(TextFormField).at(1), '3');
    await tester.tap(find.text('Empezar'));
    await tester.pumpAndSettle();

    expect(PreferenciasService.instance.onboardingHecho, isTrue);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });

  testWidgets('registers an account and creates a personal habit',
      (tester) async {
    await tester.pumpWidget(const AplicacionHabitos());
    expect(find.text('Iniciar sesión'), findsOneWidget);

    await tester.tap(find.text('Crear una cuenta'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Ana');
    await tester.enterText(find.byType(TextFormField).at(1), 'Pérez');
    await tester.enterText(find.byType(TextFormField).at(2), 'ana@example.com');
    await tester.enterText(find.byType(TextFormField).at(3), 'ana');
    await tester.enterText(find.byType(TextFormField).at(4), 'clave');
    await tester.tap(find.text('Registrarse'));
    await _pumpAfterDatabase(tester);

    final cuentas = await BaseDatosLocal.instance.cargarUsuarios();
    expect(
      cuentas.map((usuario) => usuario.nombreUsuario),
      contains('ana'),
    );
    final cuenta =
        cuentas.singleWhere((usuario) => usuario.nombreUsuario == 'ana');
    expect(cuenta.apellidos, 'Pérez');
    expect(cuenta.email, 'ana@example.com');

    await tester.runAsync(() async {
      await BaseDatosLocal.instance.guardarHabito(
        Habito(
          id: 'lectura',
          usuarioId: cuenta.id,
          nombre: 'Leer',
          color: 0xFFFF6B6B,
        ),
      );
      final estadisticas = await BaseDatosLocal.instance
          .cargarEstadisticas(usuarioId: cuenta.id);
      expect(estadisticas.single['nombre'], 'Leer');
    });
  });

  testWidgets('shows the administration panel only to the admin account',
      (tester) async {
    await tester.pumpWidget(const AplicacionHabitos());
    await tester.enterText(find.byType(TextFormField).at(0), 'admin');
    await tester.enterText(find.byType(TextFormField).at(1), 'admin');
    await tester.tap(find.text('Entrar'));
    await _pumpAfterDatabase(tester);

    expect(find.text('Gestión de usuarios'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.checklist));
    await tester.pumpAndSettle();
    expect(find.text('Gestión de hábitos'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.bar_chart));
    await tester.pumpAndSettle();
    expect(find.text('Estadísticas globales'), findsOneWidget);
  });

  testWidgets('each account sees only its own habits', (tester) async {
    final servicio = BaseDatosLocal.instance;
    await tester.runAsync(() async {
      final ana = await servicio.registrarUsuario(
        nombre: 'Ana',
        apellidos: 'Pérez',
        email: 'ana@example.com',
        nombreUsuario: 'ana',
        contrasena: 'clave',
      );
      final luis = await servicio.registrarUsuario(
        nombre: 'Luis',
        apellidos: 'García',
        email: 'luis@example.com',
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
      expect((await servicio.autenticar('ana', 'clave'))?.id, ana.id);
    });

    await tester.pumpWidget(const AplicacionHabitos());
    await tester.enterText(find.byType(TextFormField).at(0), 'ana');
    await tester.enterText(find.byType(TextFormField).at(1), 'clave');
    await tester.tap(find.text('Entrar'));
    await _pumpAfterDatabase(tester);
    expect(find.text('Mis hábitos'), findsOneWidget);
    expect(find.text('Lectura'), findsOneWidget);
    expect(find.text('Ejercicio'), findsNothing);
  });
}
