import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart'; // ← Corrección aplicada
import '../../providers/alertas_stock_admin_provider.dart';
import '../../widgets/alerta_stock_form.dart';

class AlertasStockAdminScreen extends ConsumerWidget {
  const AlertasStockAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(alertasStockAdminProvider);

    return Scaffold(
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (err, _) => Center(child: Text('$err', style: const TextStyle(color: AppColors.error))),
        data: (alertas) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: alertas.length,
          itemBuilder: (context, index) {
            final a = alertas[index];
            return Card(
              color: AppColors.surface,
              child: ListTile(
                title: Text('Producto ID: ${a.productoId}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                subtitle: Text('Min: ${a.cantidadMinima} - ${a.emailNotificacion}', style: const TextStyle(color: AppColors.textSecondary)),
                trailing: IconButton(icon: const Icon(Icons.edit, color: AppColors.accent), onPressed: () => showAlertaForm(context, ref, initial: a)),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: AppColors.onAccent),
        onPressed: () => showAlertaForm(context, ref),
      ),
    );
  }
}