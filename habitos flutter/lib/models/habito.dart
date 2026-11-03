import 'dart:convert';

/// Modelo de un hábito.
///
/// Las fechas completadas se almacenan como JSON en la tabla de hábitos.
class Habito {
  final String id;
  String usuarioId;
  String nombre;
  int color; // valor ARGB, p. ej. 0xFFFF6B6B
  String icono;
  List<String> fechasCompletadas; // fechas en formato 'yyyy-MM-dd'

  Habito({
    required this.id,
    this.usuarioId = '',
    required this.nombre,
    required this.color,
    this.icono = 'agua',
    List<String>? fechasCompletadas,
  }) : fechasCompletadas = fechasCompletadas ?? [];

  /// Objeto -> Map<String, dynamic> (listo para jsonEncode).
  Map<String, dynamic> toJson() => {
        'id': id,
        'usuarioId': usuarioId,
        'nombre': nombre,
        'color': color,
        'icono': icono,
        'fechasCompletadas': fechasCompletadas,
      };

  Map<String, Object?> toDatabase() => {
        'id': id,
        'usuario_id': usuarioId,
        'nombre': nombre,
        'color': color,
        'icono': icono,
        'fechas_completadas': jsonEncode(fechasCompletadas),
      };

  factory Habito.fromJson(Map<String, dynamic> json) => Habito(
        id: json['id'] as String,
        usuarioId: json['usuarioId'] as String? ?? '',
        nombre: json['nombre'] as String? ?? '',
        color: json['color'] as int? ?? 0xFFFF7F50,
        icono: json['icono'] as String? ?? 'agua',
        fechasCompletadas: (json['fechasCompletadas'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
      );

  factory Habito.fromDatabase(Map<String, Object?> row) => Habito(
        id: row['id'] as String,
        usuarioId: row['usuario_id'] as String,
        nombre: row['nombre'] as String,
        color: row['color'] as int,
        icono: row['icono'] as String? ?? 'agua',
        fechasCompletadas:
            (jsonDecode(row['fechas_completadas'] as String) as List<dynamic>)
                .cast<String>(),
      );

  /// Clave de fecha 'yyyy-MM-dd' (sin hora) para comparar días.
  static String claveFecha(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool completadoEn(DateTime dia) =>
      fechasCompletadas.contains(claveFecha(dia));

  bool get hechoHoy => completadoEn(DateTime.now());

  /// Marca o desmarca el hábito para hoy.
  void alternarHoy() {
    final hoy = claveFecha(DateTime.now());
    if (fechasCompletadas.contains(hoy)) {
      fechasCompletadas.remove(hoy);
    } else {
      fechasCompletadas.add(hoy);
    }
  }

  int get totalDias => fechasCompletadas.toSet().length;

  /// Racha actual: días consecutivos completados terminando hoy
  /// (o ayer, si hoy todavía no se ha marcado).
  int get rachaActual {
    final set = fechasCompletadas.toSet();
    var dia = DateTime.now();
    if (!set.contains(claveFecha(dia))) {
      dia = dia.subtract(const Duration(days: 1));
    }
    var racha = 0;
    while (set.contains(claveFecha(dia))) {
      racha++;
      dia = dia.subtract(const Duration(days: 1));
    }
    return racha;
  }
}
