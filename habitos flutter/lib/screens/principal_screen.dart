import 'package:flutter/material.dart';
// intl: DateFormat permite mostrar la fecha con nombres en español
// (p. ej. "lunes, 8 de junio").
import 'package:intl/intl.dart';

import '../models/habito.dart';
import '../services/preferencias_service.dart';
import '../widgets/habito_tile.dart';
import '../widgets/tarjeta_habito.dart';
import '../widgets/progreso_card.dart';
import 'habito_form_screen.dart';

/// Pantalla principal: saludo, progreso del día y lista de hábitos.
/// StatefulWidget: la lista cambia al marcar/crear/editar/borrar.
class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  final _prefs = PreferenciasService.instance;
  List<Habito> _habitos = [];

  @override
  void initState() {
    super.initState();
    // PERSISTENCIA: recupera la List<String> y la convierte a objetos Habito.
    _habitos = _prefs.cargarHabitos();
  }

  Future<void> _guardar() async {
    // PERSISTENCIA: cada cambio se guarda inmediatamente (jsonEncode de cada hábito).
    await _prefs.guardarHabitos(_habitos);
  }

  Future<void> _alternar(Habito h) async {
    setState(() => h.alternarHoy());
    await _guardar();
  }

  Future<void> _eliminar(Habito habito) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar hábito'),
        content: Text('¿Quieres eliminar "${habito.nombre}"? Esta acción también elimina su historial.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmado == true && mounted) {
      setState(() => _habitos.removeWhere((h) => h.id == habito.id));
      await _guardar();
    }
  }

  /// Navegación: abre el formulario y espera el resultado con Navigator.push.
  Future<void> _abrirFormulario([Habito? habito]) async {
    final resultado = await Navigator.push<ResultadoFormulario>(
      context,
      MaterialPageRoute(builder: (_) => HabitoFormScreen(habito: habito)),
    );
    if (resultado == null) return;
    setState(() {
      switch (resultado.accion) {
        case AccionFormulario.crear:
          _habitos.add(resultado.habito);
        case AccionFormulario.editar:
          final i = _habitos.indexWhere((h) => h.id == resultado.habito.id);
          if (i != -1) _habitos[i] = resultado.habito;
        case AccionFormulario.borrar:
          _habitos.removeWhere((h) => h.id == resultado.habito.id);
      }
    });
    await _guardar();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final hechos = _habitos.where((h) => h.hechoHoy).length;
    final ocultar = _prefs.ocultarCompletados;
    final visibles = ocultar ? _habitos.where((h) => !h.hechoHoy).toList() : _habitos;
    final fecha = DateFormat("EEEE, d 'de' MMMM", 'es_ES').format(DateTime.now());

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        tooltip: 'Nuevo hábito',
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          children: [
            Text(fecha, style: tema.textTheme.bodyMedium),
            Text('Hola, ${_prefs.nombreUsuario}',
                style: tema.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ProgresoCard(hechos: hechos, objetivo: _prefs.objetivoDiario),
            const SizedBox(height: 16),
            if (visibles.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: Column(children: [
                  Icon(_habitos.isEmpty ? Icons.eco : Icons.emoji_events,
                      size: 56, color: tema.colorScheme.secondary),
                  const SizedBox(height: 8),
                  Text(_habitos.isEmpty ? '¡Empieza tu primer hábito!' : '¡Todo hecho por hoy!',
                      style: tema.textTheme.titleMedium),
                ]),
              ),
            for (final h in visibles)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TarjetaHabito(
                  nombre: h.nombre,
                  color: Color(h.color),
                  completado: h.hechoHoy,
                  onCompletar: () => _alternar(h),
                  onEditar: () => _abrirFormulario(h),
                  onEliminar: () => _eliminar(h),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
