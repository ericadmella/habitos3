import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitos_app/main.dart';
import 'package:habitos_app/models/habito.dart';
import 'package:habitos_app/pantallas/habito_form_screen.dart';
import 'package:habitos_app/pantallas/estadisticas_page.dart';
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

  testWidgets('respects the device text scaler', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(2)),
        child: AplicacionHabitos(),
      ),
    );

    final context = tester.element(find.text('HábitosApp'));
    expect(MediaQuery.textScalerOf(context).scale(10), 20);
  });

  testWidgets('lets the user select an icon for a habit', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PantallaFormularioHabito()),
    );

    expect(find.text('Icono del hábito'), findsOneWidget);
    await tester.tap(find.byTooltip('Lectura'));
    await tester.pumpAndSettle();

    expect(find.text('Seleccionado: Lectura'), findsOneWidget);
  });

  testWidgets('keeps the chosen icon when editing a habit', (tester) async {
    final habito = Habito(
      id: 'caminar',
      nombre: 'Caminar',
      color: 0xFFFF6B6B,
      icono: 'caminar',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => PantallaFormularioHabito(habito: habito),
                  ),
                );
              },
              child: const Text('Editar'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    expect(find.text('Seleccionado: Caminar'), findsOneWidget);
    await tester.tap(find.byTooltip('Lectura'));
    await tester.scrollUntilVisible(
      find.text('Guardar'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(habito.icono, 'lectura');
  });

  testWidgets('shows app launch count and last-open time in statistics',
      (tester) async {
    final preferencias = PreferenciasService.instance;
    await preferencias.registrarApertura();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EstadisticasPage(
            estadisticas: const [],
            aperturas: preferencias.contadorAperturas,
            ultimaApertura: preferencias.ultimaApertura,
          ),
        ),
      ),
    );

    expect(find.text('Aperturas de la app'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Última apertura'), findsOneWidget);
    expect(find.text('Cuando registres hábitos, aquí verás sus rachas.'),
        findsOneWidget);
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

    expect(find.text('Panel de administración'), findsOneWidget);
    expect(find.text('Gestionar usuarios'), findsOneWidget);
    expect(find.text('Gestionar hábitos'), findsOneWidget);
    expect(find.text('Estadísticas globales'), findsOneWidget);
    expect(find.text('Ajustes'), findsNWidgets(2));
    await tester.tap(find.text('Gestionar usuarios'));
    await tester.pumpAndSettle();
    expect(find.text('Gestión de usuarios'), findsOneWidget);
    await tester.tap(find.text('Hábitos').last);
    await tester.pumpAndSettle();
    expect(find.text('Gestión de hábitos'), findsOneWidget);
    await tester.tap(find.text('Estadísticas').last);
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
