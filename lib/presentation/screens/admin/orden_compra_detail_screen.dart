// lib/presentation/screens/admin/orden_compra_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_inventario_app/presentation/widgets/numero_serie_form.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../domain/model/orden_compra.dart';
import '../../providers/ordenes_compra_provider.dart';

class OrdenCompraDetailScreen extends ConsumerWidget {
  final int orderId;
  const OrdenCompraDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ordenesCompraProvider);
    
    final orden = state.ordenes.where((o) => o.id == orderId).firstOrNull;

    if (orden == null) {
      return const Center(child: Text('Orden no encontrada'));
    }

    final fechaStr = orden.creadoEn != null 
        ? "${orden.creadoEn!.day.toString().padLeft(2, '0')}/${orden.creadoEn!.month.toString().padLeft(2, '0')}/${orden.creadoEn!.year}"
        : "Sin fecha";

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface, 
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Proveedor: ${orden.proveedorNombre ?? "Desconocido"}', 
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                    _buildStatusBadge(orden.estado, orden.estadoDisplay),
                  ],
                ),
                const Divider(color: AppColors.border, height: 24),
                Text('Fecha de Emisión: $fechaStr', style: const TextStyle(color: AppColors.textSecondary)),
                if (orden.usuario != null)
                  Text('Emitido por: ${orden.usuario}', style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Text('Total Estimado: \$${orden.totalEstimado.toStringAsFixed(2)}', 
                  style: const TextStyle(color: AppColors.accent, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text('Productos Solicitados', 
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          
          ...orden.detalles.map((detalle) => Card(
            color: AppColors.surface,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.border),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(detalle.productoNombre ?? 'ID Producto: ${detalle.productoId}', 
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              subtitle: Text('Cantidad: ${detalle.cantidad} | P.U. Compra: \$${detalle.precioUnitarioCompra.toStringAsFixed(2)}',
                style: const TextStyle(color: AppColors.textSecondary)),
              trailing: Text('\$${(detalle.cantidad * detalle.precioUnitarioCompra).toStringAsFixed(2)}',
                 style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          )),
          
          const SizedBox(height: 32),

          if (orden.estado == 'PENDIENTE')
            ElevatedButton.icon(
              onPressed: () {
             showNumeroSerieRegistroForm(context, ref, orden);
           },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Marcar como Recibida', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String estado, String? estadoDisplay) {
    final isPendiente = estado == 'PENDIENTE';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPendiente ? AppColors.warning.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        estadoDisplay ?? estado,
        style: TextStyle(
          color: isPendiente ? AppColors.warning : AppColors.success,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}