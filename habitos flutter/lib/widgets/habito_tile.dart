import 'package:flutter/material.dart';

import '../models/habito.dart';

/// Fila de un hábito con casilla para marcarlo como hecho hoy.
/// StatelessWidget: recibe el hábito y los callbacks desde su padre.
class HabitoTile extends StatelessWidget {
  final Habito habito;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const HabitoTile({super.key, required this.habito, required this.onToggle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hecho = habito.hechoHoy;
    final color = Color(habito.color);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(border: Border(left: BorderSide(color: color, width: 8))),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            habito.nombre,
            style: TextStyle(
              decoration: hecho ? TextDecoration.lineThrough : null,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text('Racha: ${habito.rachaActual} días'),
          trailing: Transform.scale(
            scale: 1.3,
            child: Checkbox(
              value: hecho,
              activeColor: color,
              shape: const CircleBorder(),
              onChanged: (_) => onToggle(),
            ),
          ),
        ),
      ),
    );
  }
}
