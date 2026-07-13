// lib/presentation/screens/admin/ajustes_inventario_admin_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../providers/ajuste_inventario_provider.dart';
import '../../widgets/ajuste_inventario_form.dart';

class AjustesInventarioAdminScreen extends ConsumerStatefulWidget {
  const AjustesInventarioAdminScreen({super.key});

  @override
  ConsumerState<AjustesInventarioAdminScreen> createState() => _AjustesInventarioAdminScreenState();
}

class _AjustesInventarioAdminScreenState extends ConsumerState<AjustesInventarioAdminScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ajustesInventarioProvider.notifier).cargarAjustes();
    });
  }

  Color _getColorParaAjuste(String tipo) {
    switch (tipo) {
      case 'ROBO': return AppColors.error;
      case 'DANO': return AppColors.warning;
      case 'CADUCIDAD': return Colors.orange;
      case 'ERROR': return Colors.blue;
      default: return AppColors.textSecondary;
    }
  }

  IconData _getIconParaAjuste(String tipo) {
    switch (tipo) {
      case 'ROBO': return Icons.security;
      case 'DANO': return Icons.broken_image;
      case 'CADUCIDAD': return Icons.event_busy;
      case 'ERROR': return Icons.rule;
      default: return Icons.tune;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ajustesInventarioProvider);

    final filtrados = state.ajustes.where((a) {
      final termino = _searchQuery.toLowerCase();
      return a.justificativo.toLowerCase().contains(termino) ||
             a.tipoAjuste.toLowerCase().contains(termino) ||
             a.productoId.toString().contains(termino);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAjusteInventarioForm(context, ref),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add, color: AppColors.onAccent),
        label: const Text('Nuevo Ajuste', style: TextStyle(color: AppColors.onAccent, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ajustes de Inventario', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por ID de producto o justificativo...',
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

          Expanded(
            child: Builder(builder: (_) {
              if (state.isLoading && state.ajustes.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppColors.accent));
              }
              if (state.error != null && state.ajustes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.error!, style: const TextStyle(color: AppColors.error)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.read(ajustesInventarioProvider.notifier).cargarAjustes(),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }
              if (filtrados.isEmpty) {
                return const Center(
                  child: Text('No hay ajustes registrados.', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16).copyWith(bottom: 80),
                itemCount: filtrados.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final ajuste = filtrados[i];
                  final colorTipo = _getColorParaAjuste(ajuste.tipoAjuste);
                  final fechaStr = ajuste.creadoEn != null 
                    ? "${ajuste.creadoEn!.day.toString().padLeft(2,'0')}/${ajuste.creadoEn!.month.toString().padLeft(2,'0')}/${ajuste.creadoEn!.year}"
                    : "Sin fecha";

                  return Card(
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: colorTipo.withValues(alpha: 0.1),
                        child: Icon(_getIconParaAjuste(ajuste.tipoAjuste), color: colorTipo),
                      ),
                      title: Text('Producto ID: ${ajuste.productoId}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Fecha: $fechaStr', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(ajuste.justificativo, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontStyle: FontStyle.italic)),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${ajuste.cantidad > 0 ? '+' : ''}${ajuste.cantidad}', 
                            style: TextStyle(color: colorTipo, fontWeight: FontWeight.bold, fontSize: 18)
                          ),
                          Text(ajuste.tipoAjuste, style: TextStyle(color: colorTipo, fontSize: 11)),
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