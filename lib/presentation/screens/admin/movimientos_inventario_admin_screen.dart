// lib/presentation/screens/admin/movimientos_inventario_admin_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../providers/movimiento_inventario_provider.dart';
import '../../widgets/movimiento_inventario_form.dart';

class MovimientosInventarioAdminScreen extends ConsumerStatefulWidget {
  const MovimientosInventarioAdminScreen({super.key});

  @override
  ConsumerState<MovimientosInventarioAdminScreen> createState() => _MovimientosInventarioAdminScreenState();
}

class _MovimientosInventarioAdminScreenState extends ConsumerState<MovimientosInventarioAdminScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(movimientosInventarioProvider.notifier).cargarMovimientos();
    });
  }

  Color _getColorParaTipo(String tipo) {
    switch (tipo) {
      case 'ENTRADA': return AppColors.success;
      case 'SALIDA': return AppColors.error;
      case 'AJUSTE_POS': return Colors.blue;
      case 'AJUSTE_NEG': return AppColors.warning;
      default: return AppColors.textSecondary;
    }
  }

  IconData _getIconParaTipo(String tipo) {
    switch (tipo) {
      case 'ENTRADA': return Icons.arrow_downward;
      case 'SALIDA': return Icons.arrow_upward;
      case 'AJUSTE_POS': return Icons.add_circle_outline;
      case 'AJUSTE_NEG': return Icons.remove_circle_outline;
      default: return Icons.swap_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(movimientosInventarioProvider);

    final filtrados = state.movimientos.where((m) {
      final termino = _searchQuery.toLowerCase();
      return (m.productoNombre?.toLowerCase().contains(termino) ?? false) ||
             (m.motivo?.toLowerCase().contains(termino) ?? false) ||
             (m.tipo.toLowerCase().contains(termino));
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showMovimientoInventarioForm(context, ref),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add, color: AppColors.onAccent),
        label: const Text('Nuevo Movimiento', style: TextStyle(color: AppColors.onAccent, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // ── Cabecera y Buscador ──────────────────────────────────────────
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Historial de Movimientos', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por producto, tipo o motivo...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surface2,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ],
            ),
          ),

          // ── Listado ──────────────────────────────────────
          Expanded(
            child: Builder(builder: (_) {
              if (state.isLoading && state.movimientos.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppColors.accent));
              }
              if (state.error != null && state.movimientos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.error!, style: const TextStyle(color: AppColors.error)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.read(movimientosInventarioProvider.notifier).cargarMovimientos(),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }
              if (filtrados.isEmpty) {
                return const Center(
                  child: Text('No hay movimientos registrados.', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16).copyWith(bottom: 80), // Margen para el FAB
                itemCount: filtrados.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final mov = filtrados[i];
                  final colorTipo = _getColorParaTipo(mov.tipo);
                  final fechaStr = mov.creadoEn != null 
                    ? "${mov.creadoEn!.day.toString().padLeft(2,'0')}/${mov.creadoEn!.month.toString().padLeft(2,'0')}/${mov.creadoEn!.year}"
                    : "Sin fecha";

                  return Card(
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: colorTipo.withValues(alpha: 0.1),
                        child: Icon(_getIconParaTipo(mov.tipo), color: colorTipo),
                      ),
                      title: Text(mov.productoNombre ?? 'Producto ID: ${mov.productoId}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Fecha: $fechaStr | Usuario: ${mov.usuario ?? "Sistema"}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          if (mov.motivo != null && mov.motivo!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text('Motivo: ${mov.motivo}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontStyle: FontStyle.italic)),
                          ],
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${mov.tipo.contains('SALIDA') || mov.tipo.contains('NEG') ? '-' : '+'}${mov.cantidad}', 
                            style: TextStyle(color: colorTipo, fontWeight: FontWeight.bold, fontSize: 18)
                          ),
                          Text(mov.tipoDisplay ?? mov.tipo, style: TextStyle(color: colorTipo, fontSize: 11)),
                        ],
                      ),
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