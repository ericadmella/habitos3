import 'package:flutter/material.dart';

import '../models/habito_ejemplo.dart';
import 'editar_habito_screen.dart';

/// Pantalla principal (Diseño de Interfaces): saludo, objetivo y ficha del hábito.
class FichaPrincipalScreen extends StatefulWidget {
  final String nombre;
  final int objetivo;

  const FichaPrincipalScreen({super.key, required this.nombre, required this.objetivo});

  @override
  State<FichaPrincipalScreen> createState() => _FichaPrincipalScreenState();
}

class _FichaPrincipalScreenState extends State<FichaPrincipalScreen> {
  // Datos en memoria: un único hábito de ejemplo.
  HabitoEjemplo _habito = const HabitoEjemplo(nombre: 'Beber agua', color: ColorHabito.azul);

  Future<void> _editar() async {
    // Abrimos el editor pasándole los últimos datos guardados y esperamos el resultado.
    final resultado = await Navigator.push<HabitoEjemplo>(
      context,
      MaterialPageRoute(builder: (context) => EditarHabitoScreen(habito: _habito)),
    );
    // Comprobamos mounted después del await, como en el ejemplo de clase.
    if (!mounted) return;
    // Si es null (Cancelar o flecha atrás) no cambiamos nada.
    if (resultado == null) return;
    setState(() => _habito = resultado);
  }

  void _alternarCompletado() {
    setState(() => _habito = _habito.copyWith(completado: !_habito.completado));
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final color = _habito.color.color;
    return Scaffold(
      appBar: AppBar(title: const Text('HabitosApp')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center( // NOU: centra el contenido en pantallas anchas (ordenador)
          child: ConstrainedBox( // NOU: limita el ancho máximo
            constraints: const BoxConstraints(maxWidth: 600), // NOU
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, ${widget.nombre}',
                  style: tema.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Objetivo diario: ${widget.objetivo} hábitos',
                  style: tema.textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                // Ficha del hábito
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: color,
                            child: const Icon(Icons.water_drop, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nombre del hábito destacado con TextStyle.
                                Text(
                                  _habito.nombre,
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text('Color: ${_habito.color.nombre}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _habito.completado ? 'Estado: completado hoy' : 'Estado: pendiente',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _habito.completado ? Colors.green.shade700 : tema.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _editar,
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar hábito'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _alternarCompletado,
                        icon: Icon(_habito.completado ? Icons.undo : Icons.check),
                        label: Text(_habito.completado ? 'Desmarcar' : 'Marcar hecho'),
                      ),
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
