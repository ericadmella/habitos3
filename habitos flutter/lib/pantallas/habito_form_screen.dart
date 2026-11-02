import 'package:flutter/material.dart';

import '../models/habito.dart';
import '../widgets/selector_color.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';

enum AccionFormulario { crear, editar, borrar }

/// Resultado devuelto con Navigator.pop a la pantalla principal.
class ResultadoFormulario {
  final AccionFormulario accion;
  final Habito habito;
  const ResultadoFormulario(this.accion, this.habito);
}

/// Formulario para crear, editar o borrar un hábito.
/// Esta pantalla NO guarda en preferencias: devuelve el resultado a
/// PantallaPrincipal, que es quien llama al servicio.
class PantallaFormularioHabito extends StatefulWidget {
  final Habito? habito;
  final String usuarioId;

  const PantallaFormularioHabito({super.key, this.habito, this.usuarioId = ''});

  @override
  State<PantallaFormularioHabito> createState() =>
      _PantallaFormularioHabitoState();
}

class _PantallaFormularioHabitoState extends State<PantallaFormularioHabito> {
  static const colores = [
    0xFFFF6B6B,
    0xFFFF9F43,
    0xFFFDCB6E,
    0xFF1DD1A1,
    0xFF0ABDE3,
    0xFF54A0FF,
    0xFF5F27CD,
    0xFFFF9FF3,
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late int _color;

  bool get _editando => widget.habito != null;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.habito?.nombre ?? '');
    _color = widget.habito?.color ?? colores.first;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    final nombre = _nombreCtrl.text.trim();
    if (_editando) {
      final h = widget.habito!
        ..nombre = nombre
        ..color = _color;
      Navigator.pop(context, ResultadoFormulario(AccionFormulario.editar, h));
    } else {
      final h = Habito(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(), // identificador único
        usuarioId: widget.usuarioId,
        nombre: nombre,
        color: _color,
      );
      Navigator.pop(context, ResultadoFormulario(AccionFormulario.crear, h));
    }
  }

  Future<void> _borrar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Borrar hábito?'),
        content: Text(
            'Se eliminará "${widget.habito!.nombre}" y todo su historial.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Borrar')),
        ],
      ),
    );
    if (ok == true && mounted) {
      Navigator.pop(context,
          ResultadoFormulario(AccionFormulario.borrar, widget.habito!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar hábito' : 'Nuevo hábito'),
        actions: [
          if (_editando)
            IconButton(
                onPressed: _borrar,
                icon: const Icon(Icons.delete),
                tooltip: 'Borrar'),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CampoTextoApp(
              etiqueta: 'Nombre (ej. Beber agua)',
              controller: _nombreCtrl,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'El nombre es obligatorio'
                  : null,
            ),
            const SizedBox(height: 24),
            Text('Color', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SelectorColor(
              colores: colores,
              seleccionado: _color,
              onSeleccionado: (c) => setState(() => _color = c),
            ),
            const SizedBox(height: 32),
            BotonPrincipal(texto: 'Guardar', onPressed: _guardar),
          ],
        ),
      ),
    );
  }
}
