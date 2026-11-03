import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/habito.dart';
import '../models/usuario.dart';
import '../servicios/base_datos_local.dart';
import '../servicios/preferencias_service.dart';
import '../widgets/boton_principal.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/dato_estadistica.dart';
import '../widgets/iconos_habito.dart';
import '../widgets/tarjeta_habito.dart';
import 'ajustes_screen.dart';

class PaginaAdministracion extends StatefulWidget {
  final Usuario administrador;
  final Future<void> Function() onCerrarSesion;
  final ValueChanged<bool> onTemaCambiado;
  final ValueChanged<double> onLetraCambiada;
  final VoidCallback onDatosBorrados;

  const PaginaAdministracion({
    super.key,
    required this.administrador,
    required this.onCerrarSesion,
    required this.onTemaCambiado,
    required this.onLetraCambiada,
    required this.onDatosBorrados,
  });

  @override
  State<PaginaAdministracion> createState() => _PaginaAdministracionState();
}

class _PaginaAdministracionState extends State<PaginaAdministracion> {
  final _baseDatos = BaseDatosLocal.instance;
  List<Usuario> _usuarios = [];
  List<Habito> _habitos = [];
  List<Map<String, Object?>> _estadisticas = [];
  int _pestana = 0;

  @override
  void initState() {
    super.initState();
    _recargar();
  }

  Future<void> _recargar() async {
    final usuarios = await _baseDatos.cargarUsuarios();
    final habitos = await _baseDatos.cargarHabitos();
    final estadisticas = await _baseDatos.cargarEstadisticas();
    if (!mounted) return;
    setState(() {
      _usuarios = usuarios;
      _habitos = habitos;
      _estadisticas = estadisticas;
    });
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _editarUsuario([Usuario? usuario]) async {
    final nombre = TextEditingController(text: usuario?.nombre ?? '');
    final apellidos = TextEditingController(text: usuario?.apellidos ?? '');
    final email = TextEditingController(text: usuario?.email ?? '');
    final nombreUsuario =
        TextEditingController(text: usuario?.nombreUsuario ?? '');
    final contrasena = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var esAdministrador = usuario?.esAdministrador ?? false;
    final datos = await showDialog<_DatosUsuario>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(usuario == null ? 'Crear usuario' : 'Editar usuario'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CampoTextoApp(
                    etiqueta: 'Nombre',
                    controller: nombre,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Escribe el nombre.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  CampoTextoApp(
                    etiqueta: 'Apellidos',
                    controller: apellidos,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Escribe los apellidos.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  CampoTextoApp(
                    etiqueta: 'Correo electrónico',
                    controller: email,
                    teclado: TextInputType.emailAddress,
                    validator: (value) => value == null ||
                            !value.contains('@') ||
                            !value.split('@').last.contains('.')
                        ? 'Escribe un correo válido.'
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
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Cuenta administradora'),
                    value: esAdministrador,
                    onChanged: (value) =>
                        setDialogState(() => esAdministrador = value),
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
                  _DatosUsuario(
                    nombre: nombre.text.trim(),
                    apellidos: apellidos.text.trim(),
                    email: email.text.trim(),
                    usuario: nombreUsuario.text.trim(),
                    contrasena: contrasena.text,
                    esAdministrador: esAdministrador,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
    nombre.dispose();
    apellidos.dispose();
    email.dispose();
    nombreUsuario.dispose();
    contrasena.dispose();
    if (datos == null) return;

    try {
      if (usuario == null) {
        await _baseDatos.registrarUsuario(
          nombre: datos.nombre,
          apellidos: datos.apellidos,
          email: datos.email,
          nombreUsuario: datos.usuario,
          contrasena: datos.contrasena,
          esAdministrador: datos.esAdministrador,
        );
      } else {
        final actualizado = Usuario(
          id: usuario.id,
          nombre: datos.nombre,
          apellidos: datos.apellidos,
          email: datos.email,
          nombreUsuario: datos.usuario.toLowerCase(),
          contrasena:
              datos.contrasena.isEmpty ? usuario.contrasena : datos.contrasena,
          fechaCreacion: usuario.fechaCreacion,
          esAdministrador: datos.esAdministrador,
        );
        await _baseDatos.guardarUsuario(actualizado);
      }
      if (mounted) _recargar();
    } on StateError catch (error) {
      if (mounted) _mensaje(error.message);
    }
  }

  Future<void> _eliminarUsuario(Usuario usuario) async {
    if (usuario.id == widget.administrador.id) {
      _mensaje('No puedes eliminar la cuenta con la que has iniciado sesión.');
      return;
    }
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
      await _baseDatos.eliminarUsuario(usuario.id);
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
    final fechasCompletadas = TextEditingController(
      text: habito?.fechasCompletadas.join(', ') ?? '',
    );
    final formKey = GlobalKey<FormState>();
    var icono = habito?.icono ?? IconosHabito.porDefecto;
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
    ModalRoute<dynamic>? rutaDialogo;
    final datos = await showDialog<_DatosHabito>(
      context: context,
      builder: (context) {
        rutaDialogo = ModalRoute.of(context);
        return StatefulBuilder(
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
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Escribe el nombre.'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: fechasCompletadas,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Fechas completadas',
                        hintText: 'AAAA-MM-DD, separadas por comas',
                        border: OutlineInputBorder(),
                      ),
                      validator: _validarFechas,
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
                        'Icono del hábito',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final opcion in IconosHabito.opciones)
                          ChoiceChip(
                            avatar: Icon(opcion.icono, size: 18),
                            label: Text(opcion.etiqueta),
                            selected: icono == opcion.clave,
                            onSelected: (_) =>
                                setDialogState(() => icono = opcion.clave),
                          ),
                      ],
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
                      icono: icono,
                      fechasCompletadas: _parsearFechas(fechasCompletadas.text),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
    await rutaDialogo?.completed;
    nombre.dispose();
    fechasCompletadas.dispose();
    if (datos == null) return;

    await _baseDatos.guardarHabito(
      Habito(
        id: habito?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        usuarioId: datos.usuarioId,
        nombre: datos.nombre,
        color: datos.color,
        icono: datos.icono,
        fechasCompletadas: datos.fechasCompletadas,
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
      await _baseDatos.eliminarHabito(habito.id);
      if (mounted) _recargar();
    }
  }

  Future<void> _alternarHabito(Habito habito) async {
    habito.alternarHoy();
    await _baseDatos.guardarHabito(habito);
    if (mounted) _recargar();
  }

  String? _validarFechas(String? value) {
    final texto = value ?? '';
    final partes = texto.split(',').where((fecha) => fecha.trim().isNotEmpty);
    final fechas = _parsearFechas(texto);
    if (fechas.length != partes.length) {
      return 'Usa fechas válidas con formato AAAA-MM-DD.';
    }
    if (fechas.toSet().length != fechas.length) {
      return 'No repitas fechas.';
    }
    return null;
  }

  List<String> _parsearFechas(String texto) => texto
      .split(',')
      .map((fecha) => fecha.trim())
      .where((fecha) => fecha.isNotEmpty && _fechaValida(fecha))
      .toList();

  bool _fechaValida(String fecha) {
    final parsed = DateTime.tryParse(fecha);
    return parsed != null && Habito.claveFecha(parsed) == fecha;
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
      0 => 'Panel de administración',
      1 => 'Gestión de usuarios',
      2 => 'Gestión de hábitos',
      3 => 'Estadísticas globales',
      _ => 'Ajustes',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () async => widget.onCerrarSesion(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: switch (_pestana) {
          0 => _vistaInicio(context),
          1 => _vistaUsuarios(context),
          2 => _vistaHabitos(context),
          3 => _vistaEstadisticas(context),
          _ => PantallaAjustes(
              onTemaCambiado: widget.onTemaCambiado,
              onLetraCambiada: widget.onLetraCambiada,
              onDatosBorrados: widget.onDatosBorrados,
            ),
        },
      ),
      floatingActionButton: _pestana == 0 || _pestana >= 3
          ? null
          : FloatingActionButton(
              tooltip: _pestana == 1 ? 'Crear usuario' : 'Crear hábito',
              onPressed: _pestana == 1
                  ? () => _editarUsuario()
                  : () => _editarHabito(),
              child: const Icon(Icons.add),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pestana,
        onDestinationSelected: (index) => setState(() => _pestana = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Usuarios',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Hábitos',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }

  Widget _vistaInicio(BuildContext context) {
    final tema = Theme.of(context);
    final opciones = [
      (
        titulo: 'Gestionar usuarios',
        detalle: '${_usuarios.length} cuentas registradas',
        icono: Icons.people_outline,
        pestana: 1,
      ),
      (
        titulo: 'Gestionar hábitos',
        detalle: '${_habitos.length} hábitos registrados',
        icono: Icons.checklist,
        pestana: 2,
      ),
      (
        titulo: 'Estadísticas globales',
        detalle: 'Consulta el progreso de los hábitos',
        icono: Icons.bar_chart,
        pestana: 3,
      ),
      (
        titulo: 'Ajustes',
        detalle: 'Personaliza la apariencia y los datos',
        icono: Icons.settings_outlined,
        pestana: 4,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Hola, ${widget.administrador.nombre}',
          style: tema.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Elige una opción para administrar la aplicación.',
          style: tema.textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        for (final opcion in opciones)
          Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Icon(
                opcion.icono,
                color: tema.colorScheme.primary,
                size: 28,
              ),
              title: Text(
                opcion.titulo,
                style: tema.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(opcion.detalle),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () => setState(() => _pestana = opcion.pestana),
            ),
          ),
      ],
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
              title: Text('${usuario.nombre} ${usuario.apellidos}'.trim()),
              subtitle: Text(
                '${usuario.email} · @${usuario.nombreUsuario} · ${usuario.esAdministrador ? 'Administrador' : 'Usuario'} · ${DateFormat('dd/MM/yyyy').format(usuario.fechaCreacion)}',
              ),
              trailing: usuario.esAdministrador
                  ? PopupMenuButton<String>(
                      onSelected: (accion) {
                        if (accion == 'editar') _editarUsuario(usuario);
                        if (accion == 'eliminar') _eliminarUsuario(usuario);
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'editar', child: Text('Editar')),
                        PopupMenuItem(
                            value: 'eliminar', child: Text('Eliminar')),
                      ],
                    )
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
              icono: IconosHabito.obtener(habito.icono),
              onCompletar: () => _alternarHabito(habito),
              onEditar: () => _editarHabito(habito),
              onEliminar: () => _eliminarHabito(habito),
            ),
          ),
      ],
    );
  }

  Widget _vistaEstadisticas(BuildContext context) {
    final preferencias = PreferenciasService.instance;
    final ultimaApertura = preferencias.ultimaApertura;
    final ultimaAperturaTexto = ultimaApertura == null
        ? 'Nunca'
        : DateFormat('d MMM yyyy, HH:mm', 'es_ES').format(ultimaApertura);
    final diasCompletados = _estadisticas.fold<int>(
      0,
      (total, estadistica) => total + (estadistica['dias_completados']! as int),
    );
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
        Row(
          children: [
            Expanded(
              child: DatoEstadistica(
                etiqueta: 'Aperturas de la app',
                valor: '${preferencias.contadorAperturas}',
                icono: Icons.phone_android,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DatoEstadistica(
                etiqueta: 'Última apertura',
                valor: ultimaAperturaTexto,
                icono: Icons.access_time,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (final estadistica in _estadisticas)
          Card(
            child: ListTile(
              title: Text(estadistica['nombre']! as String),
              subtitle: Text(
                '${estadistica['usuario']} · Racha: ${estadistica['racha_actual']} · Días: ${estadistica['dias_completados']}',
              ),
            ),
          ),
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
  final String apellidos;
  final String email;
  final String usuario;
  final String contrasena;
  final bool esAdministrador;

  const _DatosUsuario({
    required this.nombre,
    required this.apellidos,
    required this.email,
    required this.usuario,
    required this.contrasena,
    required this.esAdministrador,
  });
}

class _DatosHabito {
  final String nombre;
  final String usuarioId;
  final int color;
  final String icono;
  final List<String> fechasCompletadas;

  const _DatosHabito({
    required this.nombre,
    required this.usuarioId,
    required this.color,
    required this.icono,
    required this.fechasCompletadas,
  });
}
