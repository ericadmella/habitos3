import 'package:flutter/material.dart';

import 'ficha_principal_screen.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';

/// Pantalla de bienvenida (Diseño de Interfaces).
/// Pide nombre y objetivo diario y los pasa al constructor de la principal.
class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  // Un TextEditingController por campo, creados FUERA de build.
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _objetivoCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    // Liberamos los controladores.
    _nombreCtrl.dispose();
    _objetivoCtrl.dispose();
    super.dispose();
  }

  void _comenzar() {
    final nombre = _nombreCtrl.text.trim();
    final objetivo = int.tryParse(_objetivoCtrl.text.trim());
    if (nombre.isEmpty || objetivo == null || objetivo < 1) {
      setState(() => _error = 'Escribe tu nombre y un objetivo mayor que 0');
      return;
    }
    setState(() => _error = null);
    // Navegación: push + MaterialPageRoute pasando los datos al constructor.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PantallaFichaPrincipal(nombre: nombre, objetivo: objetivo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Bienvenida')),
      // SingleChildScrollView: evita que el contenido quede cortado con el teclado.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          // NOU: centra el contenido en pantallas anchas (ordenador)
          child: ConstrainedBox(
            // NOU: limita el ancho máximo
            constraints: const BoxConstraints(maxWidth: 600), // NOU
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Icon(Icons.eco_rounded,
                    size: 72, color: tema.colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'HábitosApp',
                  textAlign: TextAlign.center,
                  style: tema.textTheme.headlineLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                CampoTextoApp(
                    etiqueta: 'Nombre del usuario', controller: _nombreCtrl),
                const SizedBox(height: 16),
                CampoTextoApp(
                    etiqueta: 'Objetivo diario de hábitos',
                    controller: _objetivoCtrl,
                    teclado: TextInputType.number),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!,
                      style: TextStyle(color: tema.colorScheme.error)),
                ],
                const SizedBox(height: 24),
                BotonPrincipal(texto: 'Comenzar', onPressed: _comenzar),
              ],
            ),
          ), // NOU: cierra ConstrainedBox
        ), // NOU: cierra Center
      ),
    );
  }
}
