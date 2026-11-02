import 'package:flutter/material.dart';

/// Tarjeta de progreso del día ("2 de 5 hábitos").
class ProgresoCard extends StatelessWidget {
  final int hechos;
  final int objetivo;

  const ProgresoCard({super.key, required this.hechos, required this.objetivo});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final progreso = objetivo == 0 ? 0.0 : (hechos / objetivo).clamp(0.0, 1.0);
    return Card(
      color: tema.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$hechos de $objetivo hábitos',
              style: tema.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(value: progreso, minHeight: 14),
          ),
          const SizedBox(height: 8),
          Text(progreso >= 1
              ? '¡Objetivo diario cumplido!'
              : 'Te faltan ${objetivo - hechos} para tu objetivo'),
        ]),
      ),
    );
  }
}
