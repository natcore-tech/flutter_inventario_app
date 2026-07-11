import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../providers/promociones_admin_provider.dart';
import '../../widgets/promocion_form.dart';

class PromocionesAdminScreen extends ConsumerWidget {
    const PromocionesAdminScreen({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final promocionesState = ref.watch(promocionesAdminProvider);

    return Scaffold(
        backgroundColor: AppColors.background,
        body: promocionesState.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
            error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
            data: (promociones) {
            if (promociones.isEmpty) {
            return const Center(child: Text('No hay promociones activas', style: TextStyle(color: AppColors.textSecondary)));
            }
            return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: promociones.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
                final promo = promociones[index];
                return Container(
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                ),
                child: ListTile(
                    title: Text('Descuento: ${promo.porcentajeDescuento}%', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                    subtitle: Text('Vence: ${promo.fechaFin.day}/${promo.fechaFin.month}/${promo.fechaFin.year}', style: const TextStyle(color: AppColors.textSecondary)),
                    trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: promo.activa ? Colors.green.withValues(alpha: 0.2) : AppColors.error.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(promo.activa ? 'Activa' : 'Inactiva', style: TextStyle(color: promo.activa ? Colors.green : AppColors.error, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    onTap: () => showPromocionForm(context, ref, initial: promo),
                    ),
                );
                },
            );
            },
        ),
        floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: AppColors.onAccent),
        onPressed: () => showPromocionForm(context, ref),
        ),
        );
    }
}