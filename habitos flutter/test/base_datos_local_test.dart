import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:habitos_app/models/habito.dart';
import 'package:habitos_app/servicios/base_datos_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persists user, habit, and derived statistics in SQLite', () async {
    SharedPreferences.setMockInitialValues({});
    final baseDatos = BaseDatosLocal.instance;
    await baseDatos.inicializar(enMemoria: true);

    final usuario = await baseDatos.registrarUsuario(
      nombre: 'Ana',
      apellidos: 'Pérez',
      email: 'ana@example.com',
      nombreUsuario: 'ana',
      contrasena: 'clave',
    );
    final habito = Habito(
      id: 'lectura',
      usuarioId: usuario.id,
      nombre: 'Lectura',
      color: 0xFFFF6B6B,
      fechasCompletadas: [Habito.claveFecha(DateTime.now())],
    );
    await baseDatos.guardarHabito(habito);
    expect(
      (await baseDatos.cargarUsuarios())
          .map((cuenta) => cuenta.id)
          .contains(usuario.id),
      isTrue,
    );

    final estadisticas =
        await baseDatos.cargarEstadisticas(usuarioId: usuario.id);
    expect(estadisticas, hasLength(1));
    expect(estadisticas.single['dias_completados'], 1);
    expect((await baseDatos.autenticar('ANA', 'clave'))?.id, usuario.id);
    await baseDatos.eliminarUsuario(usuario.id);
    expect(await baseDatos.cargarHabitos(usuarioId: usuario.id), isEmpty);
    expect(await baseDatos.cargarEstadisticas(usuarioId: usuario.id), isEmpty);
  });

  test('migrates existing shared preference users and habits into SQLite',
      () async {
    final legacyUser = {
      'id': 'legacy-user',
      'nombre': 'Luis',
      'nombreUsuario': 'luis',
      'contrasena': 'clave',
      'fechaCreacion': DateTime(2025).toIso8601String(),
      'esAdministrador': false,
    };
    final legacyHabit = {
      'id': 'legacy-habit',
      'usuarioId': 'legacy-user',
      'nombre': 'Caminar',
      'color': 0xFFFF6B6B,
      'fechasCompletadas': ['2025-01-01'],
    };
    SharedPreferences.setMockInitialValues({
      'usuarios': [jsonEncode(legacyUser)],
      'habitos': [jsonEncode(legacyHabit)],
    });
    final preferencias = await SharedPreferences.getInstance();
    await BaseDatosLocal.instance.inicializar(enMemoria: true);

    expect(
      (await BaseDatosLocal.instance.cargarUsuarios())
          .map((usuario) => usuario.nombreUsuario),
      contains('luis'),
    );
    expect(
      (await BaseDatosLocal.instance.cargarHabitos(usuarioId: 'legacy-user'))
          .single
          .nombre,
      'Caminar',
    );
    expect(preferencias.getStringList('usuarios'), isNull);
    expect(preferencias.getStringList('habitos'), isNull);
  });
}
