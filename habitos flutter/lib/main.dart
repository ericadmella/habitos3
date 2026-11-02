import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'models/usuario.dart';
import 'pantallas/administracion_page.dart';
import 'pantallas/bienvenida_screen.dart';
import 'pantallas/habitos_page.dart';
import 'pantallas/login_page.dart';
import 'servicios/base_datos_local.dart';
import 'servicios/preferencias_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  final preferencias = PreferenciasService.instance;
  await preferencias.init();
  final baseDatos = BaseDatosLocal.instance;
  await baseDatos.inicializar();
  await preferencias.registrarApertura();
  final usuarioActivoId = preferencias.usuarioActivoId;
  final usuarioActivo = usuarioActivoId == null
      ? null
      : await baseDatos.buscarUsuario(usuarioActivoId);
  if (usuarioActivoId != null && usuarioActivo == null) {
    await preferencias.limpiarSesion();
  }
  runApp(
    AplicacionHabitos(
      mostrarBienvenida: !preferencias.onboardingHecho,
      usuarioInicial: usuarioActivo,
    ),
  );
}

class AplicacionHabitos extends StatefulWidget {
  final bool mostrarBienvenida;
  final Usuario? usuarioInicial;

  const AplicacionHabitos({
    super.key,
    this.mostrarBienvenida = false,
    this.usuarioInicial,
  });

  @override
  State<AplicacionHabitos> createState() => _AplicacionHabitosState();
}

class _AplicacionHabitosState extends State<AplicacionHabitos> {
  final _preferencias = PreferenciasService.instance;
  Usuario? _usuario;
  late bool _mostrarBienvenida;
  late bool _temaOscuro;
  late double _tamanoLetra;

  @override
  void initState() {
    super.initState();
    _usuario = widget.usuarioInicial;
    _mostrarBienvenida = widget.mostrarBienvenida;
    _temaOscuro = _preferencias.temaOscuro;
    _tamanoLetra = _preferencias.tamanoLetra;
  }

  Future<void> _cerrarSesion() async {
    await _preferencias.limpiarSesion();
    if (mounted) setState(() => _usuario = null);
  }

  void _reiniciarAplicacion() {
    setState(() {
      _usuario = null;
      _mostrarBienvenida = true;
      _temaOscuro = _preferencias.temaOscuro;
      _tamanoLetra = _preferencias.tamanoLetra;
    });
  }

  @override
  Widget build(BuildContext context) {
    const semilla = Color(0xFFFF7F50);
    final usuario = _usuario;
    final pantalla = _mostrarBienvenida
        ? PantallaBienvenida(
            onTerminado: () => setState(() => _mostrarBienvenida = false),
          )
        : usuario == null
            ? PaginaLogin(
                onLogin: (cuenta) async {
                  await _preferencias.guardarSesion(cuenta.id);
                  if (mounted) setState(() => _usuario = cuenta);
                },
              )
            : usuario.esAdministrador
                ? PaginaAdministracion(
                    key: ValueKey(usuario.id),
                    administrador: usuario,
                    onCerrarSesion: _cerrarSesion,
                    onTemaCambiado: (valor) =>
                        setState(() => _temaOscuro = valor),
                    onLetraCambiada: (valor) =>
                        setState(() => _tamanoLetra = valor),
                    onDatosBorrados: _reiniciarAplicacion,
                  )
                : PaginaHabitos(
                    key: ValueKey(usuario.id),
                    usuario: usuario,
                    onCerrarSesion: _cerrarSesion,
                    onTemaCambiado: (valor) =>
                        setState(() => _temaOscuro = valor),
                    onLetraCambiada: (valor) =>
                        setState(() => _tamanoLetra = valor),
                    onDatosBorrados: _reiniciarAplicacion,
                  );

    return MaterialApp(
      title: 'HábitosApp',
      debugShowCheckedModeBanner: false,
      locale: const Locale('es', 'ES'),
      supportedLocales: const [Locale('es', 'ES')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorSchemeSeed: semilla,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: semilla,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: _temaOscuro ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(_tamanoLetra)),
        child: child!,
      ),
      home: pantalla,
    );
  }
}
