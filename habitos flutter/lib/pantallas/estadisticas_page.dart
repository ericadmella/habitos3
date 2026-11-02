import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/dato_estadistica.dart';

class EstadisticasPage extends StatelessWidget {
  final List<Map<String, Object?>> estadisticas;
  final int aperturas;
  final DateTime? ultimaApertura;

  const EstadisticasPage({
    super.key,
    required this.estadisticas,
    required this.aperturas,
    required this.ultimaApertura,
  });

  @override
  Widget build(BuildContext context) {
    final diasCompletados = estadisticas.fold<int>(
      0,
      (total, estadistica) => total + (estadistica['dias_completados']! as int),
    );
    final ultimaAperturaTexto = ultimaApertura == null
        ? 'Nunca'
        : DateFormat('d MMM yyyy, HH:mm', 'es_ES').format(ultimaApertura!);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Resumen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DatoEstadistica(
                etiqueta: 'Días completados',
                valor: '$diasCompletados',
                icono: Icons.calendar_month,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DatoEstadistica(
                etiqueta: 'Aperturas de la app',
                valor: '$aperturas',
                icono: Icons.phone_android,
              ),
            ),
          ],
        ),
        DatoEstadistica(
          etiqueta: 'Última apertura',
          valor: ultimaAperturaTexto,
          icono: Icons.access_time,
        ),
        const SizedBox(height: 16),
        Text(
          'Por hábito',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        if (estadisticas.isEmpty)
          const Text('Cuando registres hábitos, aquí verás sus rachas.'),
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
