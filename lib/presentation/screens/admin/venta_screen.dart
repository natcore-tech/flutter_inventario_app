// lib/presentation/screens/admin/venta_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_inventario_app/presentation/domain/model/venta.dart';
import 'package:flutter_inventario_app/presentation/providers/venta_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../domain/model/producto_lite.dart';

Color _estadoColor(EstadoVenta e) => switch (e) {
      EstadoVenta.pagada  => AppColors.success,
      EstadoVenta.emitida => AppColors.warning,
      EstadoVenta.anulada => AppColors.error,
    };

String _estadoLabel(EstadoVenta e) => switch (e) {
      EstadoVenta.pagada  => 'Pagada',
      EstadoVenta.emitida => 'Emitida',
      EstadoVenta.anulada => 'Anulada',
    };

class VentasAdminScreen extends ConsumerWidget {
  const VentasAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(ventasAdminProvider);
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
                      const Text('Historial de Ventas',
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('${state.ventas.length} ventas',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                  IconButton(
                    onPressed: () => ref.read(ventasAdminProvider.notifier).load(),
                    icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: ref.read(ventasAdminProvider.notifier).setSearch,
                decoration: const InputDecoration(
                  hintText: 'Buscar por cliente o # de venta...',
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
                      onPressed: () => ref.read(ventasAdminProvider.notifier).load(),
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
                    const Text('🧾', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(
                      state.search.isEmpty ? 'Sin ventas registradas' : 'Sin resultados',
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
              itemBuilder: (_, i) => _VentaCard(venta: filtered[i]),
            );
          }),
        ),
      ],
    );
  }
}

class _VentaCard extends StatelessWidget {
  final Venta venta;
  const _VentaCard({required this.venta});

  @override
  Widget build(BuildContext context) {
    final color = _estadoColor(venta.estado);
    final fecha = '${venta.fechaEmision.day.toString().padLeft(2, '0')}/'
        '${venta.fechaEmision.month.toString().padLeft(2, '0')}/'
        '${venta.fechaEmision.year} '
        '${venta.fechaEmision.hour.toString().padLeft(2, '0')}:'
        '${venta.fechaEmision.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () => _showDetalle(context, venta),
      child: Opacity(
        opacity: venta.estado == EstadoVenta.anulada ? 0.55 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text('#${venta.id}',
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(venta.nombreCliente,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                    Text(fecha, style: const TextStyle(color: AppColors.textFaint, fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('\$${venta.total.toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(_estadoLabel(venta.estado),
                        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetalle(BuildContext context, Venta venta) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _VentaDetalleSheet(venta: venta),
    );
  }
}

class _VentaDetalleSheet extends ConsumerWidget {
  final Venta venta;
  const _VentaDetalleSheet({required this.venta});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anulando = ref.watch(ventasAdminProvider.select((s) => s.anulandoId)) == venta.id;
    final color = _estadoColor(venta.estado);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Venta #${venta.id}',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                  child: Text(_estadoLabel(venta.estado), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Cliente: ${venta.nombreCliente}', style: const TextStyle(color: AppColors.textSecondary)),
            Text('Cajero: ${venta.nombreCajero}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 16),

            const Text('Productos', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ...venta.detalles.map((d) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text('${d.cantidad}x ${d.nombreProducto}',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
                  Text('\$${(d.subtotalLinea ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            )),
            const Divider(color: AppColors.border, height: 24),

            _totalRow('Subtotal', venta.subtotal),
            _totalRow('IVA', venta.iva),
            _totalRow('Total', venta.total, bold: true),
            const SizedBox(height: 16),

            const Text('Pagos', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            if (venta.pagos.isEmpty)
              const Text('Sin pagos registrados', style: TextStyle(color: AppColors.textFaint, fontSize: 12))
            else
              ...venta.pagos.map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(p.nombreMetodo, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                    Text('\$${p.monto.toStringAsFixed(2)}',
                        style: const TextStyle(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
            const SizedBox(height: 24),

            if (venta.estado != EstadoVenta.anulada)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: anulando ? null : () => _confirmarAnular(context, ref),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    foregroundColor: AppColors.error,
                  ),
                  child: anulando
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.error),
                        )
                      : const Text('Anular venta'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(String label, double value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          color: bold ? AppColors.textPrimary : AppColors.textSecondary,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        )),
        Text('\$${value.toStringAsFixed(2)}', style: TextStyle(
          color: bold ? AppColors.accent : AppColors.textSecondary,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        )),
      ],
    ),
  );

  void _confirmarAnular(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Anular esta venta?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'La venta quedará marcada como anulada. Esta acción no se puede deshacer desde la app.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // cierra el diálogo de confirmación
              Navigator.pop(context); // cierra el bottom sheet de detalle
              ref.read(ventasAdminProvider.notifier).anularVenta(venta.id);
            },
            child: const Text('Anular', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}