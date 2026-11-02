/// Modelo de un hábito.
///
/// PERSISTENCIA: shared_preferences solo guarda tipos simples, así que cada
/// Habito se convierte a Map con [toJson] y luego a String con jsonEncode.
/// Al leer se hace el camino inverso: jsonDecode -> Map -> [Habito.fromJson].
class Habito {
  final String id;
  String nombre;
  int color; // valor ARGB, p. ej. 0xFFFF6B6B
  List<String> fechasCompletadas; // fechas en formato 'yyyy-MM-dd'

  Habito({
    required this.id,
    required this.nombre,
    required this.color,
    List<String>? fechasCompletadas,
  }) : fechasCompletadas = fechasCompletadas ?? [];

  /// Objeto -> Map<String, dynamic> (listo para jsonEncode).
  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'color': color,
        'fechasCompletadas': fechasCompletadas,
      };

  /// Map (resultado de jsonDecode) -> objeto Habito.
  /// Se protege contra campos null por si el JSON viene incompleto.
  factory Habito.fromJson(Map<String, dynamic> json) => Habito(
        id: json['id'] as String,
        nombre: json['nombre'] as String? ?? '',
        color: json['color'] as int? ?? 0xFFFF7F50,
        fechasCompletadas:
            (json['fechasCompletadas'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
      );

  /// Clave de fecha 'yyyy-MM-dd' (sin hora) para comparar días.
  static String claveFecha(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool completadoEn(DateTime dia) => fechasCompletadas.contains(claveFecha(dia));

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
