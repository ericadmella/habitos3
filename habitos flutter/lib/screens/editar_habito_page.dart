import 'package:flutter/material.dart';
import 'habito_form_screen.dart';
import '../models/habito.dart';

/// Nombre de pantalla usado en el enunciado ACT02; admite crear y editar.
class EditarHabitoPage extends StatelessWidget {
  final Habito? habito;
  final String usuarioId;

  const EditarHabitoPage({super.key, this.habito, this.usuarioId = ''});

  @override
  Widget build(BuildContext context) =>
      HabitoFormScreen(habito: habito, usuarioId: usuarioId);
}
