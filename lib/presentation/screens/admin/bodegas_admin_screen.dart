import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart'; // ← Aquí está la corrección (3 niveles)
import '../../providers/bodegas_admin_provider.dart';
import '../../widgets/bodega_form.dart';

class BodegasAdminScreen extends ConsumerWidget {
  const BodegasAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bodegasAdminProvider);

    return Scaffold(
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (err, _) => Center(child: Text('$err', style: const TextStyle(color: AppColors.error))),
        data: (bodegas) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bodegas.length,
          itemBuilder: (context, index) {
            final b = bodegas[index];
            return Card(
              color: AppColors.surface,
              child: ListTile(
                title: Text(b.nombre, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                subtitle: Text(b.direccion ?? 'Sin dirección', style: const TextStyle(color: AppColors.textSecondary)),
                trailing: IconButton(icon: const Icon(Icons.edit, color: AppColors.accent), onPressed: () => showBodegaForm(context, ref, initial: b)),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: AppColors.onAccent),
        onPressed: () => showBodegaForm(context, ref),
      ),
    );
  }
}