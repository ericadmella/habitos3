import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'models/usuario.dart';
import 'screens/administracion_page.dart';
import 'screens/habitos_page.dart';
import 'screens/login_page.dart';
import 'services/preferencias_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  final preferencias = PreferenciasService.instance;
  await preferencias.init();
  await preferencias.registrarApertura();
  runApp(const HabitosApp());
}

class HabitosApp extends StatefulWidget {
  const HabitosApp({super.key});

  @override
  State<HabitosApp> createState() => _HabitosAppState();
}

class _HabitosAppState extends State<HabitosApp> {
  final _preferencias = PreferenciasService.instance;
  Usuario? _usuario;
  late bool _temaOscuro;
  late double _tamanoLetra;

  @override
  void initState() {
    super.initState();
    _temaOscuro = _preferencias.temaOscuro;
    _tamanoLetra = _preferencias.tamanoLetra;
  }

  void _cerrarSesion() => setState(() => _usuario = null);

  @override
  Widget build(BuildContext context) {
    const semilla = Color(0xFFFF7F50);
    final usuario = _usuario;
    final pantalla = usuario == null
        ? LoginPage(onLogin: (cuenta) => setState(() => _usuario = cuenta))
        : usuario.esAdministrador
            ? AdministracionPage(
                key: ValueKey(usuario.id),
                administrador: usuario,
                onCerrarSesion: _cerrarSesion,
              )
            : HabitosPage(
                key: ValueKey(usuario.id),
                usuario: usuario,
                onCerrarSesion: _cerrarSesion,
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
