class Usuario {
  final String id;
  final String nombre;
  final String apellidos;
  final String email;
  final String nombreUsuario;
  final String contrasena;
  final DateTime fechaCreacion;
  final bool esAdministrador;

  const Usuario({
    required this.id,
    required this.nombre,
    this.apellidos = '',
    this.email = '',
    required this.nombreUsuario,
    required this.contrasena,
    required this.fechaCreacion,
    this.esAdministrador = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'apellidos': apellidos,
        'email': email,
        'nombreUsuario': nombreUsuario,
        'contrasena': contrasena,
        'fechaCreacion': fechaCreacion.toIso8601String(),
        'esAdministrador': esAdministrador,
      };

  Map<String, Object?> toDatabase() => {
        'id': id,
        'nombre': nombre,
        'apellidos': apellidos,
        'email': email,
        'nombre_usuario': nombreUsuario,
        'contrasena': contrasena,
        'fecha_creacion': fechaCreacion.toIso8601String(),
        'rol': esAdministrador ? 'administrador' : 'usuario',
      };

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id'] as String,
        nombre: json['nombre'] as String? ?? '',
        apellidos: json['apellidos'] as String? ?? '',
        email: json['email'] as String? ?? '',
        nombreUsuario: json['nombreUsuario'] as String? ?? '',
        contrasena: json['contrasena'] as String? ?? '',
        fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
        esAdministrador: json['esAdministrador'] as bool? ?? false,
      );

  factory Usuario.fromDatabase(Map<String, Object?> row) => Usuario(
        id: row['id'] as String,
        nombre: row['nombre'] as String,
        apellidos: row['apellidos'] as String,
        email: row['email'] as String,
        nombreUsuario: row['nombre_usuario'] as String,
        contrasena: row['contrasena'] as String,
        fechaCreacion: DateTime.parse(row['fecha_creacion'] as String),
        esAdministrador: row['rol'] == 'administrador',
      );
}
