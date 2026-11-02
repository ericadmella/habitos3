import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../servicios/base_datos_local.dart';
import '../widgets/boton_principal.dart';
import '../widgets/campo_texto_app.dart';
import 'registro_page.dart';

class PaginaLogin extends StatefulWidget {
  final Future<void> Function(Usuario) onLogin;

  const PaginaLogin({super.key, required this.onLogin});

  @override
  State<PaginaLogin> createState() => _PaginaLoginState();
}

class _PaginaLoginState extends State<PaginaLogin> {
  final _usuario = TextEditingController();
  final _contrasena = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _usuario.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (_usuario.text.trim().isEmpty || _contrasena.text.isEmpty) {
      setState(() => _error = 'Completa el usuario y la contraseña.');
      return;
    }
    final cuenta = await BaseDatosLocal.instance
        .autenticar(_usuario.text, _contrasena.text);
    if (!mounted) return;
    if (cuenta == null) {
      setState(() => _error = 'El usuario o la contraseña no son correctos.');
      return;
    }
    await widget.onLogin(cuenta);
  }

  Future<void> _abrirRegistro() async {
    final registrado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PaginaRegistro()),
    );
    if (registrado == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Cuenta creada. Ya puedes iniciar sesión.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.eco_rounded,
                    size: 68, color: tema.colorScheme.primary),
                const SizedBox(height: 12),
                Text(
                  'HábitosApp',
                  textAlign: TextAlign.center,
                  style: tema.textTheme.headlineMedium,
                ),
                const SizedBox(height: 28),
                CampoTextoApp(etiqueta: 'Usuario', controller: _usuario),
                const SizedBox(height: 16),
                CampoTextoApp(
                  etiqueta: 'Contraseña',
                  controller: _contrasena,
                  ocultar: true,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!,
                      style: TextStyle(color: tema.colorScheme.error)),
                ],
                const SizedBox(height: 22),
                BotonPrincipal(texto: 'Entrar', onPressed: _entrar),
                TextButton(
                  onPressed: _abrirRegistro,
                  child: const Text('Crear una cuenta'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Administrador de demostración: admin / admin',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
