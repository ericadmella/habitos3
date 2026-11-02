import 'package:flutter/material.dart';

import '../widgets/dato_estadistica.dart';

class EstadisticasPage extends StatelessWidget {
  final List<Map<String, Object?>> estadisticas;

  const EstadisticasPage({super.key, required this.estadisticas});

  @override
  Widget build(BuildContext context) {
    if (estadisticas.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Cuando registres hábitos, aquí verás sus rachas y días completados.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final estadistica in estadisticas)
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: Color(estadistica['color']! as int),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          estadistica['nombre']! as String,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DatoEstadistica(
                          etiqueta: 'Racha actual',
                          valor: '${estadistica['racha_actual']! as int}',
                          icono: Icons.local_fire_department,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DatoEstadistica(
                          etiqueta: 'Días completados',
                          valor: '${estadistica['dias_completados']! as int}',
                          icono: Icons.calendar_month,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
