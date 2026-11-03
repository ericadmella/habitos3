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
  await preferencias.limpiarSesion();
  await preferencias.registrarApertura();
  runApp(
    AplicacionHabitos(
      mostrarBienvenida: !preferencias.onboardingHecho,
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

  ThemeData _crearTema(Brightness brillo) {
    final tema = ThemeData(
      colorSchemeSeed: const Color(0xFFFF7F50),
      brightness: brillo,
      useMaterial3: true,
    );
    return tema.copyWith(
      textTheme: _escalarTextTheme(tema.textTheme, _tamanoLetra),
      primaryTextTheme: _escalarTextTheme(tema.primaryTextTheme, _tamanoLetra),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      theme: _crearTema(Brightness.light),
      darkTheme: _crearTema(Brightness.dark),
      themeMode: _temaOscuro ? ThemeMode.dark : ThemeMode.light,
      home: pantalla,
    );
  }
}

TextTheme _escalarTextTheme(TextTheme textTheme, double factor) {
  TextStyle? escalar(TextStyle? estilo) {
    final tamano = estilo?.fontSize;
    return estilo == null || tamano == null
        ? estilo
        : estilo.copyWith(fontSize: tamano * factor);
  }

  return textTheme.copyWith(
    displayLarge: escalar(textTheme.displayLarge),
    displayMedium: escalar(textTheme.displayMedium),
    displaySmall: escalar(textTheme.displaySmall),
    headlineLarge: escalar(textTheme.headlineLarge),
    headlineMedium: escalar(textTheme.headlineMedium),
    headlineSmall: escalar(textTheme.headlineSmall),
    titleLarge: escalar(textTheme.titleLarge),
    titleMedium: escalar(textTheme.titleMedium),
    titleSmall: escalar(textTheme.titleSmall),
    bodyLarge: escalar(textTheme.bodyLarge),
    bodyMedium: escalar(textTheme.bodyMedium),
    bodySmall: escalar(textTheme.bodySmall),
    labelLarge: escalar(textTheme.labelLarge),
    labelMedium: escalar(textTheme.labelMedium),
    labelSmall: escalar(textTheme.labelSmall),
  );
}
