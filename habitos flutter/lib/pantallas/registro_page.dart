import 'package:flutter/material.dart';

import '../servicios/base_datos_local.dart';
import '../widgets/boton_principal.dart';
import '../widgets/campo_texto_app.dart';

class PaginaRegistro extends StatefulWidget {
  const PaginaRegistro({super.key});

  @override
  State<PaginaRegistro> createState() => _PaginaRegistroState();
}

class _PaginaRegistroState extends State<PaginaRegistro> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _apellidos = TextEditingController();
  final _email = TextEditingController();
  final _usuario = TextEditingController();
  final _contrasena = TextEditingController();
  String? _error;
  bool _guardando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _apellidos.dispose();
    _email.dispose();
    _usuario.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await BaseDatosLocal.instance.registrarUsuario(
        nombre: _nombre.text,
        apellidos: _apellidos.text,
        email: _email.text,
        nombreUsuario: _usuario.text,
        contrasena: _contrasena.text,
      );
      if (mounted) Navigator.pop(context, true);
    } on StateError catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Center(
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              CampoTextoApp(
                etiqueta: 'Nombre',
                controller: _nombre,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Escribe tu nombre.'
                    : null,
              ),
              const SizedBox(height: 16),
              CampoTextoApp(
                etiqueta: 'Apellidos',
                controller: _apellidos,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Escribe tus apellidos.'
                    : null,
              ),
              const SizedBox(height: 16),
              CampoTextoApp(
                etiqueta: 'Correo electrónico',
                controller: _email,
                teclado: TextInputType.emailAddress,
                validator: (value) => value == null ||
                        !value.contains('@') ||
                        !value.split('@').last.contains('.')
                    ? 'Escribe un correo electrónico válido.'
                    : null,
              ),
              const SizedBox(height: 16),
              CampoTextoApp(
                etiqueta: 'Usuario',
                controller: _usuario,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Escribe un nombre de usuario.'
                    : null,
              ),
              const SizedBox(height: 16),
              CampoTextoApp(
                etiqueta: 'Contraseña',
                controller: _contrasena,
                ocultar: true,
                validator: (value) => value == null || value.isEmpty
                    ? 'Escribe una contraseña.'
                    : null,
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: tema.colorScheme.error)),
              ],
              const SizedBox(height: 24),
              BotonPrincipal(
                texto: _guardando ? 'Guardando…' : 'Registrarse',
                onPressed: _registrar,
                habilitado: !_guardando,
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver al inicio de sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
