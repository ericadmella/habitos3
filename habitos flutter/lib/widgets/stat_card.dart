import 'package:flutter/material.dart';

/// Tarjeta con un dato estadístico.
class StatCard extends StatelessWidget {
  final IconData icono;
  final String valor;
  final String etiqueta;

  const StatCard({super.key, required this.icono, required this.valor, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icono, color: tema.colorScheme.primary),
          const SizedBox(height: 8),
          Text(valor, style: tema.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          Text(etiqueta, style: tema.textTheme.bodySmall),
        ]),
      ),
    );
  }
}
