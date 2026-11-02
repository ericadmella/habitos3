import 'package:flutter/material.dart';

/// Botón principal con estilo compartido y acción configurable.
class BotonPrincipal extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  const BotonPrincipal({super.key, required this.texto, required this.onPressed});

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onPressed,
    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    child: Text(texto),
  );
}
