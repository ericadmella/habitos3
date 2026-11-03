import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/habito.dart';
import '../models/usuario.dart';

class BaseDatosLocal {
  BaseDatosLocal._();
  static final BaseDatosLocal instance = BaseDatosLocal._();

  Database? _baseDatos;
  DatabaseFactory? _fabrica;

  Database get _db {
    final db = _baseDatos;
    if (db == null) {
      throw StateError('BaseDatosLocal.inicializar() no se ha llamado');
    }
    return db;
  }

  Future<void> inicializar({bool enMemoria = false}) async {
    await _baseDatos?.close();
    final esEscritorio = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS);
    final usaFfi = enMemoria || esEscritorio;
    if (usaFfi) {
      sqfliteFfiInit();
      _fabrica = enMemoria ? databaseFactoryFfiNoIsolate : databaseFactoryFfi;
    } else {
      _fabrica = databaseFactory;
    }

    final fabrica = _fabrica!;
    final ruta = enMemoria
        ? inMemoryDatabasePath
        : path.join(await fabrica.getDatabasesPath(), 'habitos_app.db');
    _baseDatos = await fabrica.openDatabase(
      ruta,
      options: OpenDatabaseOptions(
        version: 2,
        onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE usuarios (
              id TEXT PRIMARY KEY,
              nombre TEXT NOT NULL,
              apellidos TEXT NOT NULL,
              email TEXT NOT NULL,
              nombre_usuario TEXT NOT NULL COLLATE NOCASE UNIQUE,
              contrasena TEXT NOT NULL,
              fecha_creacion TEXT NOT NULL,
              rol TEXT NOT NULL CHECK (rol IN ('administrador', 'usuario'))
            )
          ''');
          await db.execute('''
            CREATE TABLE habitos (
              id TEXT PRIMARY KEY,
              usuario_id TEXT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
              nombre TEXT NOT NULL,
              color INTEGER NOT NULL,
              icono TEXT NOT NULL DEFAULT 'agua',
              fechas_completadas TEXT NOT NULL DEFAULT '[]'
            )
          ''');
          await db.execute('''
            CREATE TABLE estadisticas (
              habito_id TEXT PRIMARY KEY REFERENCES habitos(id) ON DELETE CASCADE,
              racha_actual INTEGER NOT NULL DEFAULT 0,
              dias_completados INTEGER NOT NULL DEFAULT 0
            )
          ''');
          await db.execute(
              'CREATE INDEX indice_habitos_usuario ON habitos(usuario_id)');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute(
              "ALTER TABLE habitos ADD COLUMN icono TEXT NOT NULL DEFAULT 'agua'",
            );
          }
        },
      ),
    );
    await _migrarPreferenciasAntiguas();
    await _crearAdministradorSiHaceFalta();
  }

  Future<void> cerrar() async {
    await _baseDatos?.close();
    _baseDatos = null;
  }

  Future<void> _migrarPreferenciasAntiguas() async {
    final preferencias = await SharedPreferences.getInstance();
    final usuariosGuardados =
        preferencias.getStringList('usuarios') ?? const <String>[];
    final habitosGuardados =
        preferencias.getStringList('habitos') ?? const <String>[];
    if (usuariosGuardados.isEmpty && habitosGuardados.isEmpty) return;

    await _db.transaction((tx) async {
      final usuariosExistentes = await tx.query('usuarios');
      if (usuariosExistentes.isNotEmpty) return;

      for (final json in usuariosGuardados) {
        final anterior = Usuario.fromJson(
          jsonDecode(json) as Map<String, dynamic>,
        );
        final usuario = Usuario(
          id: anterior.id,
          nombre: anterior.nombre,
          apellidos: anterior.apellidos.trim().isEmpty
              ? 'No especificado'
              : anterior.apellidos,
          email: _emailValido(anterior.email)
              ? anterior.email
              : '${anterior.id}@local.invalid',
          nombreUsuario: anterior.nombreUsuario,
          contrasena: anterior.contrasena,
          fechaCreacion: anterior.fechaCreacion,
          esAdministrador: anterior.esAdministrador,
        );
        await tx.insert('usuarios', usuario.toDatabase(),
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }

      final administradores = await tx.query(
        'usuarios',
        columns: ['id'],
        where: 'rol = ?',
        whereArgs: ['administrador'],
        limit: 1,
      );
      if (administradores.isEmpty) {
        await tx.insert(
          'usuarios',
          Usuario(
            id: 'admin',
            nombre: 'Administrador',
            apellidos: 'Sistema',
            email: 'admin@habitos.local',
            nombreUsuario: 'admin',
            contrasena: 'admin',
            fechaCreacion: DateTime.now(),
            esAdministrador: true,
          ).toDatabase(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      final usuarios = await tx.query('usuarios', columns: ['id']);
      final ids = usuarios.map((row) => row['id'] as String).toSet();
      for (final json in habitosGuardados) {
        final datos = Habito.fromJson(
          jsonDecode(json) as Map<String, dynamic>,
        );
        final usuarioId =
            ids.contains(datos.usuarioId) ? datos.usuarioId : 'admin';
        final habito = Habito(
          id: datos.id,
          usuarioId: usuarioId,
          nombre: datos.nombre,
          color: datos.color,
          icono: datos.icono,
          fechasCompletadas: datos.fechasCompletadas,
        );
        await tx.insert('habitos', habito.toDatabase(),
            conflictAlgorithm: ConflictAlgorithm.ignore);
        await _guardarEstadistica(tx, habito);
      }
    });

    await preferencias.remove('usuarios');
    await preferencias.remove('habitos');
  }

  Future<void> _crearAdministradorSiHaceFalta() async {
    final administradores = await _db.query(
      'usuarios',
      where: 'rol = ?',
      whereArgs: ['administrador'],
      limit: 1,
    );
    if (administradores.isNotEmpty) return;
    await _db.insert(
      'usuarios',
      Usuario(
        id: 'admin',
        nombre: 'Administrador',
        apellidos: 'Sistema',
        email: 'admin@habitos.local',
        nombreUsuario: 'admin',
        contrasena: 'admin',
        fechaCreacion: DateTime.now(),
        esAdministrador: true,
      ).toDatabase(),
    );
  }

  Future<List<Usuario>> cargarUsuarios() async {
    final filas = await _db.query('usuarios', orderBy: 'nombre COLLATE NOCASE');
    return filas.map(Usuario.fromDatabase).toList();
  }

  Future<Usuario?> buscarUsuario(String id) async {
    final filas = await _db.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return filas.isEmpty ? null : Usuario.fromDatabase(filas.single);
  }

  Future<List<Habito>> cargarHabitos({String? usuarioId}) async {
    final filas = await _db.query(
      'habitos',
      where: usuarioId == null ? null : 'usuario_id = ?',
      whereArgs: usuarioId == null ? null : [usuarioId],
      orderBy: 'nombre COLLATE NOCASE',
    );
    return filas.map(Habito.fromDatabase).toList();
  }

  Future<Usuario?> autenticar(String nombreUsuario, String contrasena) async {
    final filas = await _db.query(
      'usuarios',
      where: 'nombre_usuario = ? AND contrasena = ?',
      whereArgs: [nombreUsuario.trim(), contrasena],
      limit: 1,
    );
    return filas.isEmpty ? null : Usuario.fromDatabase(filas.single);
  }

  Future<Usuario> registrarUsuario({
    required String nombre,
    required String apellidos,
    required String email,
    required String nombreUsuario,
    required String contrasena,
    bool esAdministrador = false,
  }) async {
    if (nombre.trim().isEmpty ||
        apellidos.trim().isEmpty ||
        !_emailValido(email) ||
        nombreUsuario.trim().isEmpty ||
        contrasena.isEmpty) {
      throw StateError('Completa todos los datos correctamente.');
    }
    final usuario = Usuario(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      nombre: nombre.trim(),
      apellidos: apellidos.trim(),
      email: email.trim().toLowerCase(),
      nombreUsuario: nombreUsuario.trim().toLowerCase(),
      contrasena: contrasena,
      fechaCreacion: DateTime.now(),
      esAdministrador: esAdministrador,
    );
    final existente = await _db.query(
      'usuarios',
      columns: ['id'],
      where: 'nombre_usuario = ? COLLATE NOCASE',
      whereArgs: [usuario.nombreUsuario],
      limit: 1,
    );
    if (existente.isNotEmpty) {
      throw StateError('Ese nombre de usuario ya está registrado.');
    }
    await _db.insert('usuarios', usuario.toDatabase());
    return usuario;
  }

  Future<void> guardarUsuario(Usuario usuario) async {
    if (usuario.nombre.trim().isEmpty ||
        usuario.apellidos.trim().isEmpty ||
        !_emailValido(usuario.email) ||
        usuario.nombreUsuario.trim().isEmpty ||
        usuario.contrasena.isEmpty) {
      throw StateError('Completa todos los datos correctamente.');
    }
    final duplicados = await _db.query(
      'usuarios',
      columns: ['id'],
      where: 'nombre_usuario = ? COLLATE NOCASE AND id != ?',
      whereArgs: [usuario.nombreUsuario.trim(), usuario.id],
      limit: 1,
    );
    if (duplicados.isNotEmpty) {
      throw StateError('Ese nombre de usuario ya está registrado.');
    }
    if (!usuario.esAdministrador) {
      final administradores = await _db.query(
        'usuarios',
        columns: ['id'],
        where: "rol = 'administrador' AND id != ?",
        whereArgs: [usuario.id],
        limit: 1,
      );
      final usuarioActual = await _db.query(
        'usuarios',
        columns: ['rol'],
        where: 'id = ?',
        whereArgs: [usuario.id],
        limit: 1,
      );
      if (usuarioActual.isNotEmpty &&
          usuarioActual.single['rol'] == 'administrador' &&
          administradores.isEmpty) {
        throw StateError('Debe quedar al menos una cuenta administradora.');
      }
    }
    final filas = await _db.update(
      'usuarios',
      usuario.toDatabase(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
    if (filas == 0) await _db.insert('usuarios', usuario.toDatabase());
  }

  Future<void> eliminarUsuario(String id) async {
    final usuario = await _db.query(
      'usuarios',
      columns: ['rol'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (usuario.isEmpty) return;
    if (usuario.single['rol'] == 'administrador') {
      final administradores = await _db.query(
        'usuarios',
        columns: ['id'],
        where: 'rol = ?',
        whereArgs: ['administrador'],
      );
      if (administradores.length == 1) {
        throw StateError('Debe quedar al menos una cuenta administradora.');
      }
    }
    await _db.delete('usuarios', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> guardarHabito(Habito habito) async {
    await _db.transaction((tx) async {
      final existente = await tx.query(
        'habitos',
        columns: ['id'],
        where: 'id = ?',
        whereArgs: [habito.id],
        limit: 1,
      );
      if (existente.isEmpty) {
        await tx.insert('habitos', habito.toDatabase());
      } else {
        await tx.update(
          'habitos',
          habito.toDatabase(),
          where: 'id = ?',
          whereArgs: [habito.id],
        );
      }
      await _guardarEstadistica(tx, habito);
    });
  }

  Future<void> _guardarEstadistica(
      DatabaseExecutor executor, Habito habito) async {
    await executor.insert(
      'estadisticas',
      {
        'habito_id': habito.id,
        'racha_actual': habito.rachaActual,
        'dias_completados': habito.totalDias,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> eliminarHabito(String id) async {
    await _db.delete('habitos', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, Object?>>> cargarEstadisticas({String? usuarioId}) =>
      _db.rawQuery('''
        SELECT h.id AS habito_id, h.nombre, h.color, h.usuario_id,
               u.nombre || ' ' || u.apellidos AS usuario,
               e.racha_actual, e.dias_completados
        FROM estadisticas e
        JOIN habitos h ON h.id = e.habito_id
        JOIN usuarios u ON u.id = h.usuario_id
        ${usuarioId == null ? '' : 'WHERE h.usuario_id = ?'}
        ORDER BY h.nombre COLLATE NOCASE
      ''', usuarioId == null ? null : [usuarioId]);

  Future<void> borrarTodo() async {
    await _db.transaction((tx) async {
      await tx.delete('estadisticas');
      await tx.delete('habitos');
      await tx.delete('usuarios');
    });
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.remove('usuarios');
    await preferencias.remove('habitos');
    await _crearAdministradorSiHaceFalta();
  }

  bool _emailValido(String email) {
    final partes = email.trim().split('@');
    return partes.length == 2 &&
        partes.first.isNotEmpty &&
        partes.last.contains('.') &&
        !partes.last.startsWith('.') &&
        !partes.last.endsWith('.');
  }
}
