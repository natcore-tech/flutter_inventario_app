import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart'; // ← Corrección aplicada
import '../../providers/ubicaciones_admin_provider.dart';
import '../../widgets/ubicacion_form.dart';

class UbicacionesAdminScreen extends ConsumerWidget {
  const UbicacionesAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ubicacionesAdminProvider);

    return Scaffold(
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (err, _) => Center(child: Text('$err', style: const TextStyle(color: AppColors.error))),
        data: (ubicaciones) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ubicaciones.length,
          itemBuilder: (context, index) {
            final u = ubicaciones[index];
            return Card(
              color: AppColors.surface,
              child: ListTile(
                title: Text(u.coordenadaExacta ?? '${u.pasillo} - ${u.estante}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                trailing: IconButton(icon: const Icon(Icons.edit, color: AppColors.accent), onPressed: () => showUbicacionForm(context, ref, initial: u)),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: AppColors.onAccent),
        onPressed: () => showUbicacionForm(context, ref),
      ),
    );
  }
}