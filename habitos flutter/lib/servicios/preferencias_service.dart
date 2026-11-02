import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasService {
  PreferenciasService._();
  static final PreferenciasService instance = PreferenciasService._();

  SharedPreferences? _preferencias;

  SharedPreferences get _p {
    final preferencias = _preferencias;
    if (preferencias == null) {
      throw StateError('PreferenciasService.init() no se ha llamado');
    }
    return preferencias;
  }

  Future<void> init() async {
    _preferencias = await SharedPreferences.getInstance();
  }

  bool get onboardingHecho => _p.getBool('onboarding_hecho') ?? false;

  String get nombreUsuario => _p.getString('nombre_usuario') ?? '';

  int get objetivoDiario => _p.getInt('objetivo_diario') ?? 3;

  String? get usuarioActivoId => _p.getString('usuario_activo_id');

  Future<void> guardarSesion(String usuarioId) =>
      _p.setString('usuario_activo_id', usuarioId);

  Future<void> limpiarSesion() => _p.remove('usuario_activo_id');

  Future<void> guardarPerfilOnboarding(String nombre, int objetivo) async {
    await _p.setString('nombre_usuario', nombre);
    await _p.setInt('objetivo_diario', objetivo);
    await _p.setBool('onboarding_hecho', true);
  }

  int get contadorAperturas => _p.getInt('contador_aperturas') ?? 0;

  DateTime? get ultimaApertura {
    final fecha = _p.getString('ultima_apertura');
    return fecha == null ? null : DateTime.tryParse(fecha);
  }

  Future<void> registrarApertura() async {
    await _p.setInt('contador_aperturas', contadorAperturas + 1);
    await _p.setString(
      'ultima_apertura',
      DateTime.now().toIso8601String(),
    );
  }

  bool get temaOscuro => _p.getBool('tema_oscuro') ?? false;

  Future<void> setTemaOscuro(bool valor) => _p.setBool('tema_oscuro', valor);

  double get tamanoLetra => _p.getDouble('tamano_letra') ?? 1.0;

  Future<void> setTamanoLetra(double valor) =>
      _p.setDouble('tamano_letra', valor);

  bool get ocultarCompletados => _p.getBool('ocultar_completados') ?? false;

  Future<void> setOcultarCompletados(bool valor) =>
      _p.setBool('ocultar_completados', valor);

  Future<void> borrarTodo() => _p.clear();
}
