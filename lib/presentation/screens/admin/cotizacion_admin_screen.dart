// lib/presentation/screens/admin/cotizacion_admin_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_inventario_app/presentation/providers/cotizacion_admin_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../domain/model/cotizacion.dart';

import '../../widgets/cotizacion_form.dart';

class CotizacionAdminScreen extends ConsumerWidget {
  const CotizacionAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(cotizacionAdminProvider);
    final filtered = state.filtered;

    return Column(
      children: [
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cotizaciones a Proveedores',
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('${state.cotizaciones.length} cotizaciones',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => showCotizacionForm(context, ref),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Nueva'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: ref.read(cotizacionAdminProvider.notifier).setSearch,
                decoration: const InputDecoration(
                  hintText: 'Buscar por código...',
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
                ),
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        Expanded(
          child: Builder(builder: (_) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.accent));
            }
            if (state.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.error!, style: const TextStyle(color: AppColors.error)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.read(cotizacionAdminProvider.notifier).load(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            if (filtered.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('📋', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(
                      state.search.isEmpty ? 'Sin cotizaciones' : 'Sin resultados',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _CotizacionCard(
                cotizacion: filtered[i],
                onDelete: () => _confirmDelete(context, ref, filtered[i]),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Cotizacion c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Eliminar cotización?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('"${c.codigoCotizacion}" se eliminará permanentemente.',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(cotizacionAdminProvider.notifier).deleteCotizacion(c.id);
            },
            child: const Text('Eliminar', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _CotizacionCard extends StatelessWidget {
  final Cotizacion cotizacion;
  final VoidCallback onDelete;
  const _CotizacionCard({required this.cotizacion, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final vencida = cotizacion.vencida;
    final color = vencida ? AppColors.error : AppColors.success;

    return GestureDetector(
      onTap: () => _showDetalle(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cotizacion.codigoCotizacion,
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('Proveedor #${cotizacion.proveedorId} · ${cotizacion.detalles.length} producto(s)',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                    child: Text(vencida ? 'Vencida' : 'Vigente',
                        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('\$${cotizacion.totalPropuesto.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppColors.error,
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetalle(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(cotizacion.codigoCotizacion,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Válida hasta: ${cotizacion.fechaValidez.day}/${cotizacion.fechaValidez.month}/${cotizacion.fechaValidez.year}',
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            const Text('Productos cotizados', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...cotizacion.detalles.map((d) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${d.cantidad}x Producto #${d.productoId}',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                  Text('\$${d.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            )),
            const Divider(color: AppColors.border, height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: Text('Total: \$${cotizacion.totalPropuesto.toStringAsFixed(2)}',
                  style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}