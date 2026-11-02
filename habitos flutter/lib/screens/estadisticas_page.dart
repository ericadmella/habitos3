import 'package:flutter/material.dart';

import '../models/habito.dart';
import '../widgets/dato_estadistica.dart';

class EstadisticasPage extends StatelessWidget {
  final List<Habito> habitos;

  const EstadisticasPage({super.key, required this.habitos});

  @override
  Widget build(BuildContext context) {
    if (habitos.isEmpty) {
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
        for (final habito in habitos)
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
                        backgroundColor: Color(habito.color),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          habito.nombre,
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
                          valor: '${habito.rachaActual}',
                          icono: Icons.local_fire_department,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DatoEstadistica(
                          etiqueta: 'Días completados',
                          valor: '${habito.totalDias}',
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
