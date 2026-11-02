import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// intl: paquete oficial de Dart para internacionalización. Aquí lo usamos para
// cargar los datos de idioma español (nombres de días y meses) y así poder
// formatear fechas con DateFormat('...', 'es_ES') en las pantallas.
import 'package:intl/date_symbol_data_local.dart';

import 'screens/bienvenida_screen.dart';
import 'screens/home_shell.dart';
import 'services/preferencias_service.dart';

Future<void> main() async {
  // Necesario antes de usar plugins (shared_preferences) antes de runApp.
  WidgetsFlutterBinding.ensureInitialized();
  // intl: inicializa los símbolos de fecha en español.
  await initializeDateFormatting('es_ES', null);
  runApp(const HabitosApp());
}

/// Raíz de la app. Es StatefulWidget porque el tema, el tamaño de letra y
/// si ya se hizo la bienvenida pueden cambiar mientras la app está abierta.
class HabitosApp extends StatefulWidget {
  const HabitosApp({super.key});

  @override
  State<HabitosApp> createState() => _HabitosAppState();
}

class _HabitosAppState extends State<HabitosApp> {
  final _prefs = PreferenciasService.instance;

  bool _cargando = true;
  bool _onboardingHecho = false;
  bool _temaOscuro = false;
  double _tamanoLetra = 1.0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  /// PERSISTENCIA: lectura asíncrona inicial.
  /// Mientras dura, _cargando = true y se muestra un CircularProgressIndicator.
  Future<void> _cargarDatos() async {
    await _prefs.init(); // obtiene la instancia de SharedPreferences
    await _prefs.registrarApertura(); // int + String: contador y fecha/hora
    setState(() {
      // En la primera ejecución estas claves no existen (null);
      // el servicio devuelve valores por defecto con el operador ??.
      _onboardingHecho = _prefs.onboardingHecho;
      _temaOscuro = _prefs.temaOscuro;
      _tamanoLetra = _prefs.tamanoLetra;
      _cargando = false;
    });
  }

  void _onBienvenidaTerminada() => setState(() => _onboardingHecho = true);

  void _onTemaCambiado(bool oscuro) => setState(() => _temaOscuro = oscuro);

  void _onLetraCambiada(double valor) => setState(() => _tamanoLetra = valor);

  /// Tras borrar todos los datos, la app vuelve al estado "recién instalada".
  void _onDatosBorrados() {
    setState(() {
      _onboardingHecho = false;
      _temaOscuro = false;
      _tamanoLetra = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    const semilla = Color(0xFFFF7F50); // coral

    Widget home;
    if (_cargando) {
      home = const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else if (!_onboardingHecho) {
      home = BienvenidaScreen(onTerminado: _onBienvenidaTerminada);
    } else {
      home = HomeShell(
        onTemaCambiado: _onTemaCambiado,
        onLetraCambiada: _onLetraCambiada,
        onDatosBorrados: _onDatosBorrados,
      );
    }

    return MaterialApp(
      title: 'HabitosApp',
      debugShowCheckedModeBanner: false,
      locale: const Locale('es', 'ES'),
      supportedLocales: const [Locale('es', 'ES')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(colorSchemeSeed: semilla, brightness: Brightness.light, useMaterial3: true),
      darkTheme: ThemeData(colorSchemeSeed: semilla, brightness: Brightness.dark, useMaterial3: true),
      themeMode: _temaOscuro ? ThemeMode.dark : ThemeMode.light,
      // Aplica el tamaño de letra elegido (double guardado en prefs) a toda la app.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(_tamanoLetra)),
        child: child!,
      ),
      // La Key fuerza a reconstruir el árbol al cambiar de bienvenida a principal.
      home: KeyedSubtree(key: ValueKey(_onboardingHecho), child: home),
    );
  }
}
