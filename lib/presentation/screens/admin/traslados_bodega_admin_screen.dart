// lib/presentation/screens/admin/traslados_bodega_admin_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../providers/traslado_bodega_provider.dart';

class TrasladosBodegaAdminScreen extends ConsumerStatefulWidget {
  const TrasladosBodegaAdminScreen({super.key});

  @override
  ConsumerState<TrasladosBodegaAdminScreen> createState() => _TrasladosBodegaAdminScreenState();
}

class _TrasladosBodegaAdminScreenState extends ConsumerState<TrasladosBodegaAdminScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(trasladosBodegaProvider.notifier).cargarTraslados();
    });
  }

  Color _getColorEstado(String estado) {
    switch (estado) {
      case 'EN_TRANSITO': return AppColors.warning;
      case 'COMPLETADO': return AppColors.success;
      case 'CANCELADO': return AppColors.error;
      default: return AppColors.textSecondary;
    }
  }

  void _confirmarCompletar(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('¿Completar Traslado?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Esto descontará el stock de la bodega origen y lo sumará a la de destino. ¿Confirmar?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(trasladosBodegaProvider.notifier).completarTraslado(id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Traslado completado con éxito'), backgroundColor: AppColors.success));
              }
            },
            child: const Text('Completar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trasladosBodegaProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/traslados/nuevo'),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add, color: AppColors.onAccent),
        label: const Text('Nuevo Traslado', style: TextStyle(color: AppColors.onAccent, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: const Text('Control de Traslados', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Builder(builder: (_) {
              if (state.isLoading && state.traslados.isEmpty) return const Center(child: CircularProgressIndicator(color: AppColors.accent));
              if (state.error != null && state.traslados.isEmpty) return Center(child: Text(state.error!, style: const TextStyle(color: AppColors.error)));
              if (state.traslados.isEmpty) return const Center(child: Text('No hay traslados registrados.', style: TextStyle(color: AppColors.textSecondary)));

              return ListView.separated(
                padding: const EdgeInsets.all(16).copyWith(bottom: 80),
                itemCount: state.traslados.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final traslado = state.traslados[i];
                  final colorEstado = _getColorEstado(traslado.estado);

                  return Card(
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
                    child: ExpansionTile(
                      iconColor: AppColors.accent,
                      collapsedIconColor: AppColors.textSecondary,
                      title: Text('Traslado #${traslado.id}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                      subtitle: Text('${traslado.bodegaOrigenNombre ?? "Origen ${traslado.bodegaOrigenId}"} ➔ ${traslado.bodegaDestinoNombre ?? "Destino ${traslado.bodegaDestinoId}"}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: colorEstado.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(traslado.estado, style: TextStyle(color: colorEstado, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      children: [
                        const Divider(color: AppColors.border),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: traslado.detalles.length,
                          itemBuilder: (ctx, j) {
                            final det = traslado.detalles[j];
                            return ListTile(
                              dense: true,
                              leading: const Icon(Icons.inventory_2_outlined, color: AppColors.textSecondary, size: 20),
                              title: Text('Producto ID: ${det.productoId}', style: const TextStyle(color: AppColors.textPrimary)),
                              trailing: Text('Cant: ${det.cantidad}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                            );
                          },
                        ),
                        if (traslado.estado == 'EN_TRANSITO')
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                                onPressed: () => _confirmarCompletar(context, traslado.id!),
                                icon: const Icon(Icons.check_circle, color: Colors.white),
                                label: const Text('Marcar como Completado', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          )
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}