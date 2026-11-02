import 'package:flutter/material.dart';
// intl: formatea la fecha y hora de la última apertura en español.
import 'package:intl/intl.dart';

import '../models/habito.dart';
import '../servicios/base_datos_local.dart';
import '../servicios/preferencias_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/dato_estadistica.dart';

/// Estadísticas. Ejemplo de StatelessWidget: no guarda estado propio,
/// simplemente lee los datos del servicio cada vez que se construye.
class PantallaEstadisticas extends StatefulWidget {
  const PantallaEstadisticas({super.key});

  @override
  State<PantallaEstadisticas> createState() => _PantallaEstadisticasState();
}

class _PantallaEstadisticasState extends State<PantallaEstadisticas> {
  late Future<List<Habito>> _habitos;

  @override
  void initState() {
    super.initState();
    _habitos = BaseDatosLocal.instance.cargarHabitos();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = PreferenciasService.instance;
    final ultima = prefs.ultimaApertura;
    final ultimaTexto = ultima == null
        ? '—'
        : DateFormat("d MMM yyyy, HH:mm", 'es_ES').format(ultima);
    final tema = Theme.of(context);

    return FutureBuilder<List<Habito>>(
      future: _habitos,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text(
                  'No se pudieron cargar las estadísticas: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final habitos = snapshot.data!;
        final totalDias = habitos.fold<int>(0, (s, h) => s + h.totalDias);
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Estadísticas',
                  style: tema.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: StatCard(
                        icono: Icons.phone_android,
                        valor: '${prefs.contadorAperturas}',
                        etiqueta: 'Aperturas')),
                const SizedBox(width: 12),
                Expanded(
                    child: DatoEstadistica(
                        icono: Icons.calendar_month,
                        valor: '$totalDias',
                        etiqueta: 'Días completados')),
              ]),
              const SizedBox(height: 12),
              DatoEstadistica(
                  icono: Icons.access_time,
                  valor: ultimaTexto,
                  etiqueta: 'Última apertura'),
              const SizedBox(height: 24),
              Text('Por hábito', style: tema.textTheme.titleLarge),
              const SizedBox(height: 8),
              if (habitos.isEmpty)
                const Text('Registra hábitos para ver tus estadísticas.'),
              for (final h in habitos)
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                        backgroundColor: Color(h.color), radius: 10),
                    title: Text(h.nombre),
                    subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(children: [
                          Expanded(
                              child: DatoEstadistica(
                                  etiqueta: 'Días completados',
                                  valor: '${h.totalDias}',
                                  icono: Icons.calendar_month)),
                          const SizedBox(width: 8),
                          Expanded(
                              child: DatoEstadistica(
                                  etiqueta: 'Racha actual',
                                  valor: '${h.rachaActual}',
                                  icono: Icons.local_fire_department,
                                  color: Colors.deepOrange))
                        ])),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
