import 'package:flutter/material.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';
import 'home_shell.dart';
import 'registro_page.dart';
import 'administracion_page.dart';

/// Pantalla de acceso para la actividad de interfaces.
/// Demo local: admin/admin abre administración; otros usuarios acceden a hábitos.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usuario = TextEditingController();
  final _contrasena = TextEditingController();
  String? _error;
  @override
  void dispose() { _usuario.dispose(); _contrasena.dispose(); super.dispose(); }

  void _entrar() {
    if (_usuario.text.trim().isEmpty || _contrasena.text.isEmpty) {
      setState(() => _error = 'Completa el usuario y la contraseña.'); return;
    }
    if (_usuario.text.trim().toLowerCase() == 'admin' && _contrasena.text == 'admin') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdministracionPage()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeShell(onTemaCambiado: (_) {}, onLetraCambiada: (_) {}, onDatosBorrados: () {})));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Iniciar sesión')),
    body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Icon(Icons.eco_rounded, size: 68, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: 12), Text('HábitosApp', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 28), CampoTextoApp(etiqueta: 'Usuario', controller: _usuario),
      const SizedBox(height: 16), CampoTextoApp(etiqueta: 'Contraseña', controller: _contrasena, ocultar: true),
      if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
      const SizedBox(height: 22), BotonPrincipal(texto: 'Entrar', onPressed: _entrar),
      TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistroPage())), child: const Text('Crear una cuenta')),
      const SizedBox(height: 8), const Text('Acceso de demostración de administrador: admin / admin', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
    ])))));
}
