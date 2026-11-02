import 'package:flutter/material.dart';

import '../services/preferencias_service.dart';

/// Ajustes: tema (bool), tamaño de letra (double), ocultar completados (bool)
/// y borrar todos los datos.
class AjustesScreen extends StatefulWidget {
  final ValueChanged<bool> onTemaCambiado;
  final ValueChanged<double> onLetraCambiada;
  final VoidCallback onDatosBorrados;

  const AjustesScreen({
    super.key,
    required this.onTemaCambiado,
    required this.onLetraCambiada,
    required this.onDatosBorrados,
  });

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  final _prefs = PreferenciasService.instance;
  late bool _oscuro;
  late double _letra;
  late bool _ocultar;

  @override
  void initState() {
    super.initState();
    // PERSISTENCIA: valores iniciales leídos del servicio (con defaults si son null).
    _oscuro = _prefs.temaOscuro;
    _letra = _prefs.tamanoLetra;
    _ocultar = _prefs.ocultarCompletados;
  }

  Future<void> _confirmarBorrado() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Borrar todos los datos?'),
        content: const Text(
            'Se eliminarán tu nombre, hábitos, estadísticas y ajustes. La app quedará como recién instalada.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Borrar')),
        ],
      ),
    );
    if (ok != true) return;
    // PERSISTENCIA: prefs.clear() elimina todas las claves.
    await _prefs.borrarTodo();
    widget.onDatosBorrados(); // vuelve a mostrar la bienvenida
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Ajustes',
              style: tema.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            child: Column(children: [
              SwitchListTile(
                title: const Text('Tema oscuro'),
                value: _oscuro,
                onChanged: (v) async {
                  setState(() => _oscuro = v);
                  await _prefs.setTemaOscuro(v); // bool
                  widget.onTemaCambiado(v);
                },
              ),
              SwitchListTile(
                title: const Text('Ocultar hábitos completados hoy'),
                value: _ocultar,
                onChanged: (v) async {
                  setState(() => _ocultar = v);
                  await _prefs.setOcultarCompletados(v); // bool
                },
              ),
            ]),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Tamaño de letra: ${(_letra * 100).round()}%', style: tema.textTheme.titleMedium),
                Slider(
                  value: _letra,
                  min: 0.8,
                  max: 1.4,
                  divisions: 12,
                  label: '${(_letra * 100).round()}%',
                  onChanged: (v) => setState(() => _letra = v),
                  // Se guarda al soltar para no escribir en disco en cada movimiento.
                  onChangeEnd: (v) async {
                    await _prefs.setTamanoLetra(v); // double
                    widget.onLetraCambiada(v);
                  },
                ),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(_prefs.nombreUsuario),
              subtitle: Text('Objetivo: ${_prefs.objetivoDiario} hábitos al día'),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: tema.colorScheme.error,
              foregroundColor: tema.colorScheme.onError,
              minimumSize: const Size.fromHeight(56),
            ),
            onPressed: _confirmarBorrado,
            icon: const Icon(Icons.delete_forever),
            label: const Text('Borrar datos'),
          ),
        ],
      ),
    );
  }
}
