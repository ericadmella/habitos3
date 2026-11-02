import 'package:flutter/material.dart';

/// Muestra una estadística con etiqueta, valor, icono y color configurables.
class DatoEstadistica extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final IconData icono;
  final Color color;
  const DatoEstadistica({super.key, required this.etiqueta, required this.valor, required this.icono, this.color = const Color(0xFFFF7F50)});

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icono, color: color), const SizedBox(height: 8),
      Text(valor, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
      Text(etiqueta, style: Theme.of(context).textTheme.bodySmall),
    ])),
  );
}
