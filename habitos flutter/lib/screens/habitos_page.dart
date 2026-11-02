import 'package:flutter/material.dart';

import '../models/habito.dart';
import '../models/usuario.dart';
import '../services/preferencias_service.dart';
import '../widgets/tarjeta_habito.dart';
import 'editar_habito_page.dart';
import 'estadisticas_page.dart';
import 'habito_form_screen.dart';

class HabitosPage extends StatefulWidget {
  final Usuario usuario;
  final VoidCallback onCerrarSesion;

  const HabitosPage({
    super.key,
    required this.usuario,
    required this.onCerrarSesion,
  });

  @override
  State<HabitosPage> createState() => _HabitosPageState();
}

class _HabitosPageState extends State<HabitosPage> {
  final _preferencias = PreferenciasService.instance;
  List<Habito> _habitos = [];
  int _pestana = 0;

  @override
  void initState() {
    super.initState();
    _recargar();
  }

  void _recargar() {
    setState(() {
      _habitos = _preferencias
          .cargarHabitos()
          .where((habito) => habito.usuarioId == widget.usuario.id)
          .toList();
    });
  }

  Future<void> _editar([Habito? habito]) async {
    final resultado = await Navigator.push<ResultadoFormulario>(
      context,
      MaterialPageRoute(
        builder: (_) => EditarHabitoPage(
          habito: habito,
          usuarioId: widget.usuario.id,
        ),
      ),
    );
    if (resultado == null || !mounted) return;

    switch (resultado.accion) {
      case AccionFormulario.crear:
      case AccionFormulario.editar:
        await _preferencias.guardarHabito(resultado.habito);
        break;
      case AccionFormulario.borrar:
        await _preferencias.eliminarHabito(resultado.habito.id);
        break;
    }
    if (mounted) _recargar();
  }

  Future<void> _alternar(Habito habito) async {
    habito.alternarHoy();
    await _preferencias.guardarHabito(habito);
    if (mounted) _recargar();
  }

  Future<void> _eliminar(Habito habito) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar hábito'),
        content: Text('¿Quieres eliminar "${habito.nombre}" y su historial?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await _preferencias.eliminarHabito(habito.id);
      if (mounted) _recargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final estadisticas = _pestana == 1;
    return Scaffold(
      appBar: AppBar(
        title: Text(estadisticas ? 'Estadísticas' : 'Mis hábitos'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: widget.onCerrarSesion,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: estadisticas
          ? EstadisticasPage(habitos: _habitos)
          : SafeArea(
              child: _habitos.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.eco_outlined,
                                size: 64, color: tema.colorScheme.primary),
                            const SizedBox(height: 12),
                            Text(
                              '¡Hola, ${widget.usuario.nombre}!',
                              style: tema.textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Todavía no tienes hábitos. Crea el primero con el botón +.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Hola, ${widget.usuario.nombre}',
                            style: tema.textTheme.headlineSmall,
                          ),
                        ),
                        for (final habito in _habitos)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: TarjetaHabito(
                              nombre: habito.nombre,
                              color: Color(habito.color),
                              completado: habito.hechoHoy,
                              onCompletar: () => _alternar(habito),
                              onEditar: () => _editar(habito),
                              onEliminar: () => _eliminar(habito),
                            ),
                          ),
                      ],
                    ),
            ),
      floatingActionButton: estadisticas
          ? null
          : FloatingActionButton(
              tooltip: 'Crear hábito',
              onPressed: () => _editar(),
              child: const Icon(Icons.add),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pestana,
        onDestinationSelected: (index) => setState(() => _pestana = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.checklist),
            label: 'Hábitos',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
          ),
        ],
      ),
    );
  }
}
