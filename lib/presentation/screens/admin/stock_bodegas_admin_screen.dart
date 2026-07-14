import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart'; // ← Corrección aplicada
import '../../providers/stock_bodegas_admin_provider.dart';
import '../../providers/bodegas_admin_provider.dart';
import '../../widgets/stock_bodega_form.dart';

class StockBodegasAdminScreen extends ConsumerWidget {
  const StockBodegasAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stockBodegasAdminProvider);
    final bodegas = ref.watch(bodegasAdminProvider).valueOrNull ?? [];

    return Scaffold(
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (err, _) => Center(child: Text('$err', style: const TextStyle(color: AppColors.error))),
        data: (stocks) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: stocks.length,
          itemBuilder: (context, index) {
            final s = stocks[index];
            return Card(
              color: AppColors.surface,
              child: ListTile(
                title: Text(s.productoNombre ?? 'Producto ${s.productoId}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                subtitle: Text(s.bodegaNombre ?? 'Bodega ${s.bodegaId}', style: const TextStyle(color: AppColors.textSecondary)),
                trailing: Text('Cant: ${s.cantidad}', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 16)),
                onTap: () => showStockBodegaForm(context, ref, initial: s, bodegas: bodegas, productos: []), 
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: AppColors.onAccent),
        onPressed: () => showStockBodegaForm(context, ref, bodegas: bodegas, productos: []), 
      ),
    );
  }
}