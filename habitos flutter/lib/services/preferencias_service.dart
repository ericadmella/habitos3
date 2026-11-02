import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/habito.dart';
import '../models/usuario.dart';

/// Claves en constantes: así no hay cadenas sueltas repartidas por el código
/// y evitamos errores de escritura al leer/guardar.
class PrefsKeys {
  PrefsKeys._();

  static const String onboardingHecho = 'onboarding_hecho'; // bool
  static const String nombreUsuario = 'nombre_usuario'; // String
  static const String objetivoDiario = 'objetivo_diario'; // int
  static const String habitos = 'habitos'; // List<String>
  static const String usuarios = 'usuarios'; // List<String>
  static const String contadorAperturas = 'contador_aperturas'; // int
  static const String ultimaApertura = 'ultima_apertura'; // String (ISO 8601)
  static const String temaOscuro = 'tema_oscuro'; // bool
  static const String tamanoLetra = 'tamano_letra'; // double
  static const String ocultarCompletados = 'ocultar_completados'; // bool
}

/// CAPA DE SERVICIO: concentra TODO el acceso a SharedPreferences.
/// Las pantallas nunca llaman a SharedPreferences directamente, solo a esta clase.
///
/// Se implementa como singleton para tener una única instancia en toda la app.
class PreferenciasService {
  PreferenciasService._();
  static final PreferenciasService instance = PreferenciasService._();

  SharedPreferences? _prefs;

  /// Obtiene la instancia de SharedPreferences (operación asíncrona).
  /// Debe llamarse una vez al arrancar (ver main.dart).
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    if (_p.getStringList(PrefsKeys.usuarios) == null) {
      final admin = Usuario(
        id: 'admin',
        nombre: 'Administrador',
        nombreUsuario: 'admin',
        contrasena: 'admin',
        fechaCreacion: DateTime.now(),
        esAdministrador: true,
      );
      await _guardarUsuarios([admin]);
    }
  }

  SharedPreferences get _p {
    final p = _prefs;
    if (p == null) {
      throw StateError('PreferenciasService.init() no se ha llamado');
    }
    return p;
  }

  // ---------------------------------------------------------------------------
  // bool: bienvenida completada.
  // En la primera ejecución getBool devuelve null -> usamos ?? false.
  // ---------------------------------------------------------------------------
  bool get onboardingHecho => _p.getBool(PrefsKeys.onboardingHecho) ?? false;

  // ---------------------------------------------------------------------------
  // String + int: datos del usuario.
  // ---------------------------------------------------------------------------
  String get nombreUsuario => _p.getString(PrefsKeys.nombreUsuario) ?? '';

  int get objetivoDiario => _p.getInt(PrefsKeys.objetivoDiario) ?? 3;

  /// Guarda nombre (String), objetivo (int) y marca la bienvenida (bool).
  Future<void> guardarPerfilOnboarding(String nombre, int objetivo) async {
    await _p.setString(PrefsKeys.nombreUsuario, nombre);
    await _p.setInt(PrefsKeys.objetivoDiario, objetivo);
    await _p.setBool(PrefsKeys.onboardingHecho, true);
  }

  // ---------------------------------------------------------------------------
  // List<String>: hábitos serializados como JSON.
  // ---------------------------------------------------------------------------

  /// Lee la lista de Strings y convierte cada uno con jsonDecode + fromJson.
  /// Si la clave no existe (primera ejecución) devuelve una lista vacía.
  List<Habito> cargarHabitos() {
    final lista = _p.getStringList(PrefsKeys.habitos);
    if (lista == null) return [];
    return lista
        .map((s) => Habito.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  /// Convierte cada hábito con toJson + jsonEncode y guarda la List<String>.
  Future<void> guardarHabitos(List<Habito> habitos) async {
    final lista = habitos.map((h) => jsonEncode(h.toJson())).toList();
    await _p.setStringList(PrefsKeys.habitos, lista);
  }

  Future<void> guardarHabito(Habito habito) async {
    final habitos = cargarHabitos();
    final index = habitos.indexWhere((h) => h.id == habito.id);
    if (index < 0) {
      habitos.add(habito);
    } else {
      habitos[index] = habito;
    }
    await guardarHabitos(habitos);
  }

  Future<void> eliminarHabito(String id) async {
    await guardarHabitos(cargarHabitos().where((h) => h.id != id).toList());
  }

  List<Usuario> cargarUsuarios() {
    final lista = _p.getStringList(PrefsKeys.usuarios) ?? [];
    return lista
        .map((s) => Usuario.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Usuario? autenticar(String nombreUsuario, String contrasena) {
    final usuario = nombreUsuario.trim().toLowerCase();
    for (final cuenta in cargarUsuarios()) {
      if (cuenta.nombreUsuario.toLowerCase() == usuario &&
          cuenta.contrasena == contrasena) {
        return cuenta;
      }
    }
    return null;
  }

  Future<Usuario> registrarUsuario({
    required String nombre,
    required String nombreUsuario,
    required String contrasena,
  }) async {
    if (nombre.trim().isEmpty ||
        nombreUsuario.trim().isEmpty ||
        contrasena.isEmpty) {
      throw StateError('Completa todos los datos del usuario.');
    }
    final usuarioNormalizado = nombreUsuario.trim().toLowerCase();
    if (cargarUsuarios()
        .any((u) => u.nombreUsuario.toLowerCase() == usuarioNormalizado)) {
      throw StateError('Ese nombre de usuario ya está registrado.');
    }
    final nuevo = Usuario(
      id: '${DateTime.now().microsecondsSinceEpoch}-${cargarUsuarios().length}',
      nombre: nombre.trim(),
      nombreUsuario: usuarioNormalizado,
      contrasena: contrasena,
      fechaCreacion: DateTime.now(),
    );
    await guardarUsuario(nuevo);
    return nuevo;
  }

  Future<void> guardarUsuario(Usuario usuario) async {
    final usuarios = cargarUsuarios();
    final nombreNormalizado = usuario.nombreUsuario.trim().toLowerCase();
    if (usuarios.any((u) =>
        u.id != usuario.id &&
        u.nombreUsuario.toLowerCase() == nombreNormalizado)) {
      throw StateError('Ese nombre de usuario ya está registrado.');
    }
    final index = usuarios.indexWhere((u) => u.id == usuario.id);
    if (index >= 0) {
      usuarios[index] = usuario;
    } else {
      usuarios.add(usuario);
    }
    await _guardarUsuarios(usuarios);
  }

  Future<void> eliminarUsuario(String id) async {
    final usuarios = cargarUsuarios();
    final index = usuarios.indexWhere((u) => u.id == id);
    if (index >= 0 && usuarios[index].esAdministrador) {
      throw StateError('No se puede eliminar la cuenta de administrador.');
    }
    await _guardarUsuarios(cargarUsuarios().where((u) => u.id != id).toList());
    await guardarHabitos(
        cargarHabitos().where((h) => h.usuarioId != id).toList());
  }

  Future<void> _guardarUsuarios(List<Usuario> usuarios) async {
    await _p.setStringList(
      PrefsKeys.usuarios,
      usuarios.map((u) => jsonEncode(u.toJson())).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // int + String: estadísticas de apertura.
  // ---------------------------------------------------------------------------
  int get contadorAperturas => _p.getInt(PrefsKeys.contadorAperturas) ?? 0;

  /// Fecha/hora de la última apertura, o null si nunca se ha abierto.
  DateTime? get ultimaApertura {
    final s = _p.getString(PrefsKeys.ultimaApertura);
    return s == null ? null : DateTime.tryParse(s);
  }

  /// Se llama una vez en cada arranque: suma 1 al contador y guarda la hora.
  Future<void> registrarApertura() async {
    await _p.setInt(PrefsKeys.contadorAperturas, contadorAperturas + 1);
    await _p.setString(
        PrefsKeys.ultimaApertura, DateTime.now().toIso8601String());
  }

  // ---------------------------------------------------------------------------
  // bool + double: ajustes.
  // ---------------------------------------------------------------------------
  bool get temaOscuro => _p.getBool(PrefsKeys.temaOscuro) ?? false;

  Future<void> setTemaOscuro(bool valor) =>
      _p.setBool(PrefsKeys.temaOscuro, valor);

  double get tamanoLetra => _p.getDouble(PrefsKeys.tamanoLetra) ?? 1.0;

  Future<void> setTamanoLetra(double valor) =>
      _p.setDouble(PrefsKeys.tamanoLetra, valor);

  bool get ocultarCompletados =>
      _p.getBool(PrefsKeys.ocultarCompletados) ?? false;

  Future<void> setOcultarCompletados(bool valor) =>
      _p.setBool(PrefsKeys.ocultarCompletados, valor);

  // ---------------------------------------------------------------------------
  // Borrado total: la app queda como recién instalada.
  // ---------------------------------------------------------------------------
  Future<void> borrarTodo() async {
    await _p.clear();
  }
}
