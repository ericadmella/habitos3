import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/habito.dart';
import '../models/usuario.dart';
import '../services/preferencias_service.dart';
import '../widgets/boton_principal.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/dato_estadistica.dart';
import '../widgets/tarjeta_habito.dart';

class AdministracionPage extends StatefulWidget {
  final Usuario administrador;
  final VoidCallback onCerrarSesion;

  const AdministracionPage({
    super.key,
    required this.administrador,
    required this.onCerrarSesion,
  });

  @override
  State<AdministracionPage> createState() => _AdministracionPageState();
}

class _AdministracionPageState extends State<AdministracionPage> {
  final _preferencias = PreferenciasService.instance;
  List<Usuario> _usuarios = [];
  List<Habito> _habitos = [];
  int _pestana = 0;

  @override
  void initState() {
    super.initState();
    _recargar();
  }

  void _recargar() {
    setState(() {
      _usuarios = _preferencias.cargarUsuarios();
      _habitos = _preferencias.cargarHabitos();
    });
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _editarUsuario([Usuario? usuario]) async {
    final nombre = TextEditingController(text: usuario?.nombre ?? '');
    final nombreUsuario =
        TextEditingController(text: usuario?.nombreUsuario ?? '');
    final contrasena = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final datos = await showDialog<_DatosUsuario>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(usuario == null ? 'Crear usuario' : 'Editar usuario'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CampoTextoApp(
                  etiqueta: 'Nombre completo',
                  controller: nombre,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Escribe el nombre.'
                      : null,
                ),
                const SizedBox(height: 12),
                CampoTextoApp(
                  etiqueta: 'Usuario',
                  controller: nombreUsuario,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Escribe el usuario.'
                      : null,
                ),
                const SizedBox(height: 12),
                CampoTextoApp(
                  etiqueta: usuario == null
                      ? 'Contraseña'
                      : 'Nueva contraseña (opcional)',
                  controller: contrasena,
                  ocultar: true,
                  validator: (value) =>
                      usuario == null && (value == null || value.isEmpty)
                          ? 'Escribe una contraseña.'
                          : null,
                ),
                if (usuario != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Creada el ${DateFormat('dd/MM/yyyy').format(usuario.fechaCreacion)}',
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          BotonPrincipal(
            texto: 'Guardar',
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(
                context,
                _DatosUsuario(
                  nombre: nombre.text.trim(),
                  usuario: nombreUsuario.text.trim(),
                  contrasena: contrasena.text,
                ),
              );
            },
          ),
        ],
      ),
    );
    nombre.dispose();
    nombreUsuario.dispose();
    contrasena.dispose();
    if (datos == null) return;

    try {
      if (usuario == null) {
        await _preferencias.registrarUsuario(
          nombre: datos.nombre,
          nombreUsuario: datos.usuario,
          contrasena: datos.contrasena,
        );
      } else {
        final actualizado = Usuario(
          id: usuario.id,
          nombre: datos.nombre,
          nombreUsuario: datos.usuario.toLowerCase(),
          contrasena:
              datos.contrasena.isEmpty ? usuario.contrasena : datos.contrasena,
          fechaCreacion: usuario.fechaCreacion,
          esAdministrador: usuario.esAdministrador,
        );
        await _preferencias.guardarUsuario(actualizado);
      }
      if (mounted) _recargar();
    } on StateError catch (error) {
      if (mounted) _mensaje(error.message);
    }
  }

  Future<void> _eliminarUsuario(Usuario usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text(
          'Se eliminarán también los hábitos de ${usuario.nombre}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      await _preferencias.eliminarUsuario(usuario.id);
      if (mounted) _recargar();
    } on StateError catch (error) {
      if (mounted) _mensaje(error.message);
    }
  }

  Future<void> _editarHabito([Habito? habito]) async {
    final usuarios = _usuarios.where((u) => !u.esAdministrador).toList();
    if (usuarios.isEmpty) {
      _mensaje('Crea primero un usuario para asignarle hábitos.');
      return;
    }
    final nombre = TextEditingController(text: habito?.nombre ?? '');
    final formKey = GlobalKey<FormState>();
    var usuarioId = usuarios.any((u) => u.id == habito?.usuarioId)
        ? habito!.usuarioId
        : usuarios.first.id;
    var color = habito?.color ?? 0xFFFF6B6B;
    const colores = [
      0xFFFF6B6B,
      0xFFFF9F43,
      0xFFFDCB6E,
      0xFF1DD1A1,
      0xFF0ABDE3,
      0xFF54A0FF,
      0xFF5F27CD,
      0xFFFF9FF3,
    ];
    final datos = await showDialog<_DatosHabito>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(habito == null ? 'Crear hábito' : 'Editar hábito'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CampoTextoApp(
                    etiqueta: 'Nombre del hábito',
                    controller: nombre,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Escribe el nombre.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: usuarioId,
                    decoration: const InputDecoration(labelText: 'Usuario'),
                    items: [
                      for (final usuario in usuarios)
                        DropdownMenuItem(
                          value: usuario.id,
                          child: Text(usuario.nombre),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => usuarioId = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Color',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final opcion in colores)
                        ChoiceChip(
                          label: CircleAvatar(
                            radius: 10,
                            backgroundColor: Color(opcion),
                          ),
                          selected: color == opcion,
                          onSelected: (_) =>
                              setDialogState(() => color = opcion),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            BotonPrincipal(
              texto: 'Guardar',
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(
                  context,
                  _DatosHabito(
                    nombre: nombre.text.trim(),
                    usuarioId: usuarioId,
                    color: color,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
    nombre.dispose();
    if (datos == null) return;

    await _preferencias.guardarHabito(
      Habito(
        id: habito?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        usuarioId: datos.usuarioId,
        nombre: datos.nombre,
        color: datos.color,
        fechasCompletadas: habito?.fechasCompletadas,
      ),
    );
    if (mounted) _recargar();
  }

  Future<void> _eliminarHabito(Habito habito) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar hábito'),
        content: Text('¿Quieres eliminar "${habito.nombre}" y su historial?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await _preferencias.eliminarHabito(habito.id);
      if (mounted) _recargar();
    }
  }

  Future<void> _alternarHabito(Habito habito) async {
    habito.alternarHoy();
    await _preferencias.guardarHabito(habito);
    if (mounted) _recargar();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.administrador.esAdministrador) {
      return Scaffold(
        appBar: AppBar(title: const Text('Acceso restringido')),
        body: const Center(
          child:
              Text('Esta pantalla solo está disponible para administración.'),
        ),
      );
    }

    final titulo = switch (_pestana) {
      0 => 'Gestión de usuarios',
      1 => 'Gestión de hábitos',
      _ => 'Estadísticas globales',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: widget.onCerrarSesion,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: switch (_pestana) {
          0 => _vistaUsuarios(context),
          1 => _vistaHabitos(context),
          _ => _vistaEstadisticas(context),
        },
      ),
      floatingActionButton: _pestana == 2
          ? null
          : FloatingActionButton(
              tooltip: _pestana == 0 ? 'Crear usuario' : 'Crear hábito',
              onPressed: _pestana == 0
                  ? () => _editarUsuario()
                  : () => _editarHabito(),
              child: const Icon(Icons.add),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pestana,
        onDestinationSelected: (index) => setState(() => _pestana = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            label: 'Usuarios',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist),
            label: 'Hábitos',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
          ),
        ],
      ),
    );
  }

  Widget _vistaUsuarios(BuildContext context) {
    if (_usuarios.isEmpty) return const Center(child: Text('No hay usuarios.'));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final usuario in _usuarios)
          Card(
            child: ListTile(
              leading: Icon(
                usuario.esAdministrador
                    ? Icons.admin_panel_settings
                    : Icons.person,
              ),
              title: Text(usuario.nombre),
              subtitle: Text(
                '@${usuario.nombreUsuario} · ${DateFormat('dd/MM/yyyy').format(usuario.fechaCreacion)}',
              ),
              trailing: usuario.esAdministrador
                  ? const Chip(label: Text('Admin'))
                  : PopupMenuButton<String>(
                      onSelected: (accion) {
                        if (accion == 'editar') _editarUsuario(usuario);
                        if (accion == 'eliminar') _eliminarUsuario(usuario);
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'editar', child: Text('Editar')),
                        PopupMenuItem(
                            value: 'eliminar', child: Text('Eliminar')),
                      ],
                    ),
            ),
          ),
      ],
    );
  }

  Widget _vistaHabitos(BuildContext context) {
    if (_habitos.isEmpty) {
      return const Center(child: Text('No hay hábitos registrados.'));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final habito in _habitos)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TarjetaHabito(
              nombre: '${habito.nombre} · ${_nombreUsuario(habito.usuarioId)}',
              color: Color(habito.color),
              completado: habito.hechoHoy,
              onCompletar: () => _alternarHabito(habito),
              onEditar: () => _editarHabito(habito),
              onEliminar: () => _eliminarHabito(habito),
            ),
          ),
      ],
    );
  }

  Widget _vistaEstadisticas(BuildContext context) {
    final diasCompletados =
        _habitos.fold<int>(0, (total, habito) => total + habito.totalDias);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Resumen de la aplicación',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DatoEstadistica(
                etiqueta: 'Usuarios',
                valor: '${_usuarios.where((u) => !u.esAdministrador).length}',
                icono: Icons.people_outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DatoEstadistica(
                etiqueta: 'Hábitos',
                valor: '${_habitos.length}',
                icono: Icons.checklist,
                color: Colors.teal,
              ),
            ),
          ],
        ),
        DatoEstadistica(
          etiqueta: 'Días completados',
          valor: '$diasCompletados',
          icono: Icons.calendar_month,
        ),
        const SizedBox(height: 16),
        for (final usuario in _usuarios.where((u) => !u.esAdministrador))
          Card(
            child: ListTile(
              title: Text(usuario.nombre),
              subtitle: Text(
                '${_habitos.where((h) => h.usuarioId == usuario.id).length} hábitos',
              ),
            ),
          ),
      ],
    );
  }

  String _nombreUsuario(String id) {
    for (final usuario in _usuarios) {
      if (usuario.id == id) return usuario.nombre;
    }
    return 'Sin usuario';
  }
}

class _DatosUsuario {
  final String nombre;
  final String usuario;
  final String contrasena;

  const _DatosUsuario({
    required this.nombre,
    required this.usuario,
    required this.contrasena,
  });
}

class _DatosHabito {
  final String nombre;
  final String usuarioId;
  final int color;

  const _DatosHabito({
    required this.nombre,
    required this.usuarioId,
    required this.color,
  });
}
