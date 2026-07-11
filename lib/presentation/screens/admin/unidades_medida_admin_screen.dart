import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../providers/unidades_medida_admin_provider.dart';
import '../../widgets/unidad_medida_form.dart';

class UnidadesMedidaAdminScreen extends ConsumerWidget {
    const UnidadesMedidaAdminScreen({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final unidadesState = ref.watch(unidadesMedidaAdminProvider);

    return Scaffold(
        backgroundColor: AppColors.background,
        body: unidadesState.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
            error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
            data: (unidades) {
            if (unidades.isEmpty) {
                return const Center(child: Text('No hay unidades de medida', style: TextStyle(color: AppColors.textSecondary)));
            }
            return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: unidades.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
                final und = unidades[index];
                return Container(
                    decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                ),
                child: ListTile(
                    title: Text(und.nombre, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                    subtitle: Text(und.abreviatura, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
                    trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                    onPressed: () => showUnidadMedidaForm(context, ref, initial: und),
                    ),
                    ),
                );
                },
            );
            },
        ),
        floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: AppColors.onAccent),
        onPressed: () => showUnidadMedidaForm(context, ref),
        ),
    );
    }
}