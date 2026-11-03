import 'package:flutter/material.dart';

class OpcionIconoHabito {
  final String clave;
  final String etiqueta;
  final IconData icono;

  const OpcionIconoHabito(this.clave, this.etiqueta, this.icono);
}

abstract final class IconosHabito {
  static const String porDefecto = 'agua';

  static const opciones = [
    OpcionIconoHabito('agua', 'Agua', Icons.water_drop),
    OpcionIconoHabito('ejercicio', 'Ejercicio', Icons.fitness_center),
    OpcionIconoHabito('lectura', 'Lectura', Icons.menu_book),
    OpcionIconoHabito('meditacion', 'Meditación', Icons.self_improvement),
    OpcionIconoHabito('alimentacion', 'Alimentación', Icons.restaurant),
    OpcionIconoHabito('descanso', 'Descanso', Icons.bedtime),
    OpcionIconoHabito('caminar', 'Caminar', Icons.directions_walk),
    OpcionIconoHabito('ahorro', 'Ahorro', Icons.savings),
    OpcionIconoHabito('musica', 'Música', Icons.music_note),
    OpcionIconoHabito('mascotas', 'Mascotas', Icons.pets),
    OpcionIconoHabito('salud', 'Salud', Icons.medication),
    OpcionIconoHabito('limpieza', 'Limpieza', Icons.cleaning_services),
  ];

  static IconData obtener(String clave) => opciones
      .firstWhere(
        (opcion) => opcion.clave == clave,
        orElse: () => opciones.first,
      )
      .icono;
}
