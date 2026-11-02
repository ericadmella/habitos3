import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/habito.dart';

/// Claves en constantes: así no hay cadenas sueltas repartidas por el código
/// y evitamos errores de escritura al leer/guardar.
class PrefsKeys {
  PrefsKeys._();

  static const String onboardingHecho = 'onboarding_hecho'; // bool
  static const String nombreUsuario = 'nombre_usuario'; // String
  static const String objetivoDiario = 'objetivo_diario'; // int
  static const String habitos = 'habitos'; // List<String>
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
    _prefs ??= await SharedPreferences.getInstance();
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
  Future<void> guardarUsuario(String nombre, int objetivo) async {
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
    await _p.setString(PrefsKeys.ultimaApertura, DateTime.now().toIso8601String());
  }

  // ---------------------------------------------------------------------------
  // bool + double: ajustes.
  // ---------------------------------------------------------------------------
  bool get temaOscuro => _p.getBool(PrefsKeys.temaOscuro) ?? false;

  Future<void> setTemaOscuro(bool valor) => _p.setBool(PrefsKeys.temaOscuro, valor);

  double get tamanoLetra => _p.getDouble(PrefsKeys.tamanoLetra) ?? 1.0;

  Future<void> setTamanoLetra(double valor) => _p.setDouble(PrefsKeys.tamanoLetra, valor);

  bool get ocultarCompletados => _p.getBool(PrefsKeys.ocultarCompletados) ?? false;

  Future<void> setOcultarCompletados(bool valor) =>
      _p.setBool(PrefsKeys.ocultarCompletados, valor);

  // ---------------------------------------------------------------------------
  // Borrado total: la app queda como recién instalada.
  // ---------------------------------------------------------------------------
  Future<void> borrarTodo() async {
    await _p.clear();
  }
}
