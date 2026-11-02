import 'package:flutter/material.dart';

import 'ajustes_screen.dart';
import 'estadisticas_screen.dart';
import 'principal_screen.dart';

/// Contenedor con barra de navegación inferior entre las 3 pantallas principales.
/// StatefulWidget: guarda qué pestaña está seleccionada.
class HomeShell extends StatefulWidget {
  final ValueChanged<bool> onTemaCambiado;
  final ValueChanged<double> onLetraCambiada;
  final VoidCallback onDatosBorrados;

  const HomeShell({
    super.key,
    required this.onTemaCambiado,
    required this.onLetraCambiada,
    required this.onDatosBorrados,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _indice = 0;

  @override
  Widget build(BuildContext context) {
    // Cada pestaña se construye de nuevo al seleccionarla, así lee
    // siempre los datos más recientes guardados en preferencias.
    final paginas = [
      const PrincipalScreen(),
      const EstadisticasScreen(),
      AjustesScreen(
        onTemaCambiado: widget.onTemaCambiado,
        onLetraCambiada: widget.onLetraCambiada,
        onDatosBorrados: widget.onDatosBorrados,
      ),
    ];

    return Scaffold(
      body: paginas[_indice],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.check_circle_outline), selectedIcon: Icon(Icons.check_circle), label: 'Hoy'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Estadísticas'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}
