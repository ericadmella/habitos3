import 'package:flutter/material.dart';

/// Tarjeta independiente del modelo: recibe los datos y acciones por constructor.
class TarjetaHabito extends StatelessWidget {
  final String nombre;
  final Color color;
  final bool completado;
  final IconData icono;
  final VoidCallback onCompletar;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const TarjetaHabito(
      {super.key,
      required this.nombre,
      required this.color,
      required this.completado,
      this.icono = Icons.check_circle_outline,
      required this.onCompletar,
      required this.onEditar,
      required this.onEliminar});

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
              border: Border(left: BorderSide(color: color, width: 6))),
          child: ListTile(
            leading:
                Icon(completado ? Icons.check_circle : icono, color: color),
            title: Text(nombre,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    decoration:
                        completado ? TextDecoration.lineThrough : null)),
            subtitle: Text(completado ? 'Completado hoy' : 'Pendiente de hoy'),
            onTap: onEditar,
            trailing: Wrap(spacing: 0, children: [
              IconButton(
                  tooltip: completado ? 'Desmarcar' : 'Completar',
                  onPressed: onCompletar,
                  icon: Icon(
                      completado
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: color)),
              IconButton(
                  tooltip: 'Editar',
                  onPressed: onEditar,
                  icon: const Icon(Icons.edit_outlined)),
              IconButton(
                  tooltip: 'Eliminar',
                  onPressed: onEliminar,
                  icon: const Icon(Icons.delete_outline)),
            ]),
          ),
        ),
      );
}
