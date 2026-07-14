// lib/presentation/screens/admin/devolucion_cliente_admin_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_inventario_app/presentation/providers/devolucion_cliente_admin_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../domain/model/devolucion_cliente.dart';
import '../../widgets/devolucion_cliente_form.dart';

class DevolucionClienteAdminScreen extends ConsumerWidget {
  const DevolucionClienteAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(devolucionAdminProvider);

    return Column(
      children: [
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Devoluciones',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('${state.devoluciones.length} registradas',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => showDevolucionForm(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nueva'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
              ),
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
                      onPressed: () => ref.read(devolucionAdminProvider.notifier).load(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            if (state.devoluciones.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('↩️', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 12),
                    Text('Sin devoluciones registradas',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.devoluciones.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _DevolucionCard(
                devolucion: state.devoluciones[i],
                onDelete: () => _confirmDelete(context, ref, state.devoluciones[i]),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, DevolucionCliente d) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Eliminar devolución?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Este registro se eliminará permanentemente.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(devolucionAdminProvider.notifier).deleteDevolucion(d.id);
            },
            child: const Text('Eliminar', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _DevolucionCard extends StatelessWidget {
  final DevolucionCliente devolucion;
  final VoidCallback onDelete;
  const _DevolucionCard({required this.devolucion, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = switch (devolucion.estadoProducto) {
      EstadoProductoDevuelto.bueno => AppColors.success,
      EstadoProductoDevuelto.danio => AppColors.error,
      EstadoProductoDevuelto.usado => AppColors.warning,
    };
    final fecha = '${devolucion.fechaDevolucion.day.toString().padLeft(2,'0')}/'
        '${devolucion.fechaDevolucion.month.toString().padLeft(2,'0')}/'
        '${devolucion.fechaDevolucion.year}';

    return Container(
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
                Text('Producto #${devolucion.productoId} · ${devolucion.cantidad} un.',
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(devolucion.motivo,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                Text(fecha, style: const TextStyle(color: AppColors.textFaint, fontSize: 11)),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                  child: Text(estadoProductoLabel(devolucion.estadoProducto),
                      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppColors.error,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}