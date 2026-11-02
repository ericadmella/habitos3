import 'package:flutter/material.dart';

import '../models/habito_ejemplo.dart';

/// Editar hábito (Diseño de Interfaces).
/// Guardar -> Navigator.pop(context, resultado). Cancelar / flecha -> pop sin resultado (null).
class EditarHabitoScreen extends StatefulWidget {
  final HabitoEjemplo habito;

  const EditarHabitoScreen({super.key, required this.habito});

  @override
  State<EditarHabitoScreen> createState() => _EditarHabitoScreenState();
}

class _EditarHabitoScreenState extends State<EditarHabitoScreen> {
  // Controlador creado fuera de build e inicializado con el nombre recibido.
  late final TextEditingController _nombreCtrl;
  late ColorHabito _colorSeleccionado;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.habito.nombre);
    _colorSeleccionado = widget.habito.color;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    final nombre = _nombreCtrl.text.trim();
    final resultado = widget.habito.copyWith(
      nombre: nombre.isEmpty ? widget.habito.nombre : nombre,
      color: _colorSeleccionado,
    );
    Navigator.pop(context, resultado);
  }

  void _cancelar() {
    Navigator.pop(context); // devuelve null: no se aplican cambios
  }

  Widget _botonColor(ColorHabito c) {
    final seleccionado = c == _colorSeleccionado;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => setState(() => _colorSeleccionado = c),
        style: ElevatedButton.styleFrom(
          backgroundColor: c.color,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          side: seleccionado ? const BorderSide(color: Colors.black, width: 3) : BorderSide.none,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (seleccionado) const Icon(Icons.check, size: 18, color: Colors.white),
            if (seleccionado) const SizedBox(width: 4),
            Text(c.nombre),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      // La flecha de la AppBar hace Navigator.pop sin resultado (null).
      appBar: AppBar(title: const Text('Editar hábito')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center( // NOU: centra el contenido en pantallas anchas (ordenador)
          child: ConstrainedBox( // NOU: limita el ancho máximo
            constraints: const BoxConstraints(maxWidth: 600), // NOU
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del hábito',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Color', style: tema.textTheme.titleMedium),
                const SizedBox(height: 8),
                // Botones de color agrupados en una Row.
                Row(
                  children: [
                    _botonColor(ColorHabito.azul),
                    const SizedBox(width: 8),
                    _botonColor(ColorHabito.verde),
                    const SizedBox(width: 8),
                    _botonColor(ColorHabito.naranja),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Seleccionado: ${_colorSeleccionado.nombre}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: _colorSeleccionado.color),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(onPressed: _cancelar, child: const Text('Cancelar')),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(onPressed: _guardar, child: const Text('Guardar')),
                    ),
                  ],
                ),
              ],
            ),
          ), // NOU: cierra ConstrainedBox
        ), // NOU: cierra Center
      ),
    );
  }
}
