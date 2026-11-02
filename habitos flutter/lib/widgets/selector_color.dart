import 'package:flutter/material.dart';

/// Fila horizontal de círculos de color para elegir el color del hábito.
class SelectorColor extends StatelessWidget {
  final List<int> colores;
  final int seleccionado;
  final ValueChanged<int> onSeleccionado;

  const SelectorColor({
    super.key,
    required this.colores,
    required this.seleccionado,
    required this.onSeleccionado,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: colores.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final c = colores[i];
          final activo = c == seleccionado;
          return GestureDetector(
            onTap: () => onSeleccionado(c),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: activo ? Theme.of(context).colorScheme.onSurface : Colors.transparent,
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Color(c),
                child: activo ? const Icon(Icons.check, color: Colors.white) : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
