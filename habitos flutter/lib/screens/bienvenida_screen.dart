import 'package:flutter/material.dart';

import '../services/preferencias_service.dart';

/// Pantalla de bienvenida (solo la primera vez).
/// StatefulWidget: controla los TextField y los mensajes de error.
class BienvenidaScreen extends StatefulWidget {
  final VoidCallback onTerminado;

  const BienvenidaScreen({super.key, required this.onTerminado});

  @override
  State<BienvenidaScreen> createState() => _BienvenidaScreenState();
}

class _BienvenidaScreenState extends State<BienvenidaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _objetivoCtrl = TextEditingController(text: '3');
  bool _guardando = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _objetivoCtrl.dispose();
    super.dispose();
  }

  Future<void> _empezar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    // PERSISTENCIA: guarda String (nombre), int (objetivo) y bool (onboarding).
    await PreferenciasService.instance
        .guardarUsuario(_nombreCtrl.text.trim(), int.parse(_objetivoCtrl.text));
    if (!mounted) return;
    widget.onTerminado();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 32),
              Icon(Icons.eco_rounded, size: 80, color: tema.colorScheme.primary),
              const SizedBox(height: 16),
              Text('¡Bienvenido a HabitosApp!',
                  style: tema.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Cuéntanos un poco sobre ti para empezar.', style: tema.textTheme.bodyLarge),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nombreCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Tu nombre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Escribe tu nombre' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _objetivoCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Objetivo diario de hábitos',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1 || n > 50) return 'Introduce un número entre 1 y 50';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _guardando ? null : _empezar,
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                child: _guardando
                    ? const SizedBox(
                        width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Empezar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
