import 'package:flutter/material.dart';

/// Campo de texto reutilizable para formularios de toda la aplicación.
class CampoTextoApp extends StatelessWidget {
  final String etiqueta;
  final TextEditingController controller;
  final bool ocultar;
  final TextInputType? teclado;
  final String? Function(String?)? validator;

  const CampoTextoApp(
      {super.key,
      required this.etiqueta,
      required this.controller,
      this.ocultar = false,
      this.teclado,
      this.validator});

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        obscureText: ocultar,
        keyboardType: teclado,
        validator: validator,
        decoration: InputDecoration(
            labelText: etiqueta, border: const OutlineInputBorder()),
      );
}
