import 'package:flutter/material.dart';

/// Vista inicial de administración para la actividad. Las operaciones reales
/// sobre usuarios necesitan el modelo y servicio de usuarios de Acceso a Datos.
class AdministracionPage extends StatelessWidget {
  const AdministracionPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Administración'), actions: [IconButton(tooltip: 'Cerrar sesión', onPressed: () => Navigator.popUntil(context, (r) => r.isFirst), icon: const Icon(Icons.logout))]),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Text('Panel de administrador', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8), const Text('Esta zona está separada de la vista de usuario. Conecta cada opción con el servicio de datos para habilitar las operaciones definitivas.'),
      const SizedBox(height: 20),
      Card(child: ListTile(leading: const Icon(Icons.people_outline), title: const Text('Gestión de usuarios'), subtitle: const Text('Consultar, crear, editar y eliminar usuarios'), onTap: () => _pendiente(context))),
      Card(child: ListTile(leading: const Icon(Icons.checklist), title: const Text('Gestión de hábitos'), subtitle: const Text('Consultar y administrar hábitos'), onTap: () => _pendiente(context))),
      Card(child: ListTile(leading: const Icon(Icons.bar_chart), title: const Text('Estadísticas'), subtitle: const Text('Consultar estadísticas globales'), onTap: () => _pendiente(context))),
    ]),
  );
  static void _pendiente(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pendiente de conectar con el servicio de datos.')));
}
