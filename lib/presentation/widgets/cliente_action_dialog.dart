// lib/presentation/widgets/cliente_action_dialog.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../domain/model/cliente.dart';

Future<bool?> showConfirmActionDialog(BuildContext context, Cliente cliente, String action) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('¿$action a ${cliente.nombres}?'),
      content: const Text('Esta acción afectará el estado del cliente en el sistema.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
          child: Text(action),
        ),
      ],
    ),
  );
}