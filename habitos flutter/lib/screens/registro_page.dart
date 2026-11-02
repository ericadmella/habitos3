import 'package:flutter/material.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';

/// Formulario de registro de demostración. La persistencia de usuarios requiere
/// añadir un modelo/servicio de usuarios a la capa de Acceso a Datos.
class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});
  @override
  State<RegistroPage> createState() => _RegistroPageState();
}
class _RegistroPageState extends State<RegistroPage> {
  final _nombre = TextEditingController();
  final _usuario = TextEditingController();
  final _contrasena = TextEditingController();
  String? _error;
  @override
  void dispose() { _nombre.dispose(); _usuario.dispose(); _contrasena.dispose(); super.dispose(); }
  void _registrar() {
    if (_nombre.text.trim().isEmpty || _usuario.text.trim().isEmpty || _contrasena.text.isEmpty) {
      setState(() => _error = 'Todos los campos son obligatorios.'); return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Formulario validado. Conecta el servicio de usuarios para guardar la cuenta.')));
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Crear cuenta')), body: ListView(padding: const EdgeInsets.all(24), children: [
    CampoTextoApp(etiqueta: 'Nombre completo', controller: _nombre), const SizedBox(height: 16),
    CampoTextoApp(etiqueta: 'Usuario', controller: _usuario), const SizedBox(height: 16),
    CampoTextoApp(etiqueta: 'Contraseña', controller: _contrasena, ocultar: true),
    if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
    const SizedBox(height: 24), BotonPrincipal(texto: 'Registrarse', onPressed: _registrar),
  ]));
}
