import 'package:flutter/material.dart';

import '../models/habito.dart';
import '../models/usuario.dart';
import '../servicios/base_datos_local.dart';
import '../servicios/preferencias_service.dart';
import 'ajustes_screen.dart';
import '../widgets/progreso_card.dart';
import '../widgets/tarjeta_habito.dart';
import 'editar_habito_page.dart';
import 'estadisticas_page.dart';
import 'habito_form_screen.dart';

class PaginaHabitos extends StatefulWidget {
  final Usuario usuario;
  final Future<void> Function() onCerrarSesion;
  final ValueChanged<bool> onTemaCambiado;
  final ValueChanged<double> onLetraCambiada;
  final VoidCallback onDatosBorrados;

  const PaginaHabitos({
    super.key,
    required this.usuario,
    required this.onCerrarSesion,
    required this.onTemaCambiado,
    required this.onLetraCambiada,
    required this.onDatosBorrados,
  });

  @override
  State<PaginaHabitos> createState() => _PaginaHabitosState();
}

class _PaginaHabitosState extends State<PaginaHabitos> {
  final _baseDatos = BaseDatosLocal.instance;
  final _preferencias = PreferenciasService.instance;
  List<Habito> _habitos = [];
  List<Map<String, Object?>> _estadisticas = [];
  int _pestana = 0;

  @override
  void initState() {
    super.initState();
    _recargar();
  }

  Future<void> _recargar() async {
    final habitos =
        await _baseDatos.cargarHabitos(usuarioId: widget.usuario.id);
    final estadisticas = await _baseDatos.cargarEstadisticas(
      usuarioId: widget.usuario.id,
    );
    if (!mounted) return;
    setState(() {
      _habitos = habitos;
      _estadisticas = estadisticas;
    });
  }

  Future<void> _editar([Habito? habito]) async {
    final resultado = await Navigator.push<ResultadoFormulario>(
      context,
      MaterialPageRoute(
        builder: (_) => PaginaEditarHabito(
          habito: habito,
          usuarioId: widget.usuario.id,
        ),
      ),
    );
    if (resultado == null || !mounted) return;

    switch (resultado.accion) {
      case AccionFormulario.crear:
      case AccionFormulario.editar:
        await _baseDatos.guardarHabito(resultado.habito);
        break;
      case AccionFormulario.borrar:
        await _baseDatos.eliminarHabito(resultado.habito.id);
        break;
    }
    if (mounted) _recargar();
  }

  Future<void> _alternar(Habito habito) async {
    habito.alternarHoy();
    await _baseDatos.guardarHabito(habito);
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
      await _baseDatos.eliminarHabito(habito.id);
      if (mounted) _recargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final estadisticas = _pestana == 1;
    final ajustes = _pestana == 2;
    final completados = _habitos.where((habito) => habito.hechoHoy).length;
    final habitosVisibles = _preferencias.ocultarCompletados
        ? _habitos.where((habito) => !habito.hechoHoy).toList()
        : _habitos;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ajustes
              ? 'Ajustes'
              : estadisticas
                  ? 'Estadísticas'
                  : 'Mis hábitos',
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () async => widget.onCerrarSesion(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ajustes
          ? PantallaAjustes(
              onTemaCambiado: widget.onTemaCambiado,
              onLetraCambiada: widget.onLetraCambiada,
              onDatosBorrados: widget.onDatosBorrados,
            )
          : estadisticas
              ? EstadisticasPage(
                  estadisticas: _estadisticas,
                  aperturas: _preferencias.contadorAperturas,
                  ultimaApertura: _preferencias.ultimaApertura,
                )
              : SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    children: [
                      Text(
                        'Hola, ${widget.usuario.nombre}',
                        style: tema.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      ProgresoCard(
                        hechos: completados,
                        objetivo: _preferencias.objetivoDiario,
                      ),
                      if (habitosVisibles.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 32),
                          child: Text(
                            _habitos.isEmpty
                                ? 'Todavía no tienes hábitos. Crea el primero con el botón +.'
                                : '¡Has completado todos los hábitos de hoy!',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      for (final habito in habitosVisibles)
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
      floatingActionButton: estadisticas || ajustes
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
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
