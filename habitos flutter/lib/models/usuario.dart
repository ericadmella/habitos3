class Usuario {
  final String id;
  final String nombre;
  final String nombreUsuario;
  final String contrasena;
  final DateTime fechaCreacion;
  final bool esAdministrador;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.nombreUsuario,
    required this.contrasena,
    required this.fechaCreacion,
    this.esAdministrador = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'nombreUsuario': nombreUsuario,
        'contrasena': contrasena,
        'fechaCreacion': fechaCreacion.toIso8601String(),
        'esAdministrador': esAdministrador,
      };

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id'] as String,
        nombre: json['nombre'] as String? ?? '',
        nombreUsuario: json['nombreUsuario'] as String? ?? '',
        contrasena: json['contrasena'] as String? ?? '',
        fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
        esAdministrador: json['esAdministrador'] as bool? ?? false,
      );
}
