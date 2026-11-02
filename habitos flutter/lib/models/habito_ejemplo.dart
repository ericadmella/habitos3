import 'package:flutter/material.dart';

/// Colores disponibles en el editor (tres opciones con su nombre).
enum ColorHabito {
  azul('Azul', Colors.blue),
  verde('Verde', Colors.green),
  naranja('Naranja', Colors.orange);

  final String nombre;
  final Color color;
  const ColorHabito(this.nombre, this.color);
}

/// Hábito de ejemplo en memoria para la actividad de Diseño de Interfaces.
/// Es inmutable: el editor devuelve una copia nueva con copyWith.
class HabitoEjemplo {
  final String nombre;
  final ColorHabito color;
  final bool completado;

  const HabitoEjemplo({
    required this.nombre,
    required this.color,
    this.completado = false,
  });

  HabitoEjemplo copyWith({String? nombre, ColorHabito? color, bool? completado}) {
    return HabitoEjemplo(
      nombre: nombre ?? this.nombre,
      color: color ?? this.color,
      completado: completado ?? this.completado,
    );
  }
}
