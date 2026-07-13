// lib/presentation/screens/admin/ordenes_compra_admin_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_inventario_app/presentation/widgets/orden_compra_form.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../domain/model/orden_compra.dart';
import '../../providers/ordenes_compra_provider.dart';

class OrdenesCompraAdminScreen extends ConsumerStatefulWidget {
  const OrdenesCompraAdminScreen({super.key});

  @override
  ConsumerState<OrdenesCompraAdminScreen> createState() => _OrdenesCompraAdminScreenState();
}

class _OrdenesCompraAdminScreenState extends ConsumerState<OrdenesCompraAdminScreen> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ordenesCompraProvider.notifier).cargarOrdenes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordenesCompraProvider);

    return Column(
      children: [
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Órdenes de Compra',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22, fontWeight: FontWeight.bold,
                      )),
                  Text(
                    '${state.ordenes.length} registradas',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showOrdenCompraForm(context, ref);
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nueva'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: Builder(builder: (_) {
            if (state.isLoading && state.ordenes.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              );
            }
            
            if (state.error != null && state.ordenes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.error!, style: const TextStyle(color: AppColors.error)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.read(ordenesCompraProvider.notifier).cargarOrdenes(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state.ordenes.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textSecondary),
                    SizedBox(height: 12),
                    Text('Sin órdenes de compra', 
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.ordenes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _OrderCard(orden: state.ordenes[i]),
            );
          }),
        ),
      ],
    );
  }
}


class _OrderCard extends StatelessWidget {
  final OrdenCompra orden;
  const _OrderCard({required this.orden});

  @override
  Widget build(BuildContext context) {
    final fechaStr = orden.creadoEn != null 
        ? "${orden.creadoEn!.day.toString().padLeft(2, '0')}/${orden.creadoEn!.month.toString().padLeft(2, '0')}/${orden.creadoEn!.year}"
        : "Sin fecha";

    final isPendiente = orden.estado == 'PENDIENTE';

    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          context.go('/admin/ordenes-compra/${orden.id}');
        },
        title: Text(
          'Orden #${orden.codigoOrden ?? orden.id}', 
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Proveedor: ${orden.proveedorNombre ?? "Desconocido"}', 
                 style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            Text('Fecha: $fechaStr | Total: \$${orden.totalEstimado.toStringAsFixed(2)}', 
                 style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isPendiente ? AppColors.warning.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            orden.estadoDisplay ?? orden.estado, 
            style: TextStyle(
              color: isPendiente ? AppColors.warning : AppColors.success, 
              fontSize: 11, fontWeight: FontWeight.bold
            )
          ),
        ),
      ),
    );
  }
}