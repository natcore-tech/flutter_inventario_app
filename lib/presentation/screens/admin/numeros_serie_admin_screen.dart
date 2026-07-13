// lib/presentation/screens/admin/numeros_serie_admin_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../domain/model/numero_serie.dart';
import '../../providers/numero_serie_provider.dart';

class NumerosSerieAdminScreen extends ConsumerStatefulWidget {
  const NumerosSerieAdminScreen({super.key});

  @override
  ConsumerState<NumerosSerieAdminScreen> createState() => _NumerosSerieAdminScreenState();
}

class _NumerosSerieAdminScreenState extends ConsumerState<NumerosSerieAdminScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(numerosSerieProvider.notifier).cargarNumerosSerie();
    });
  }

  void _mostrarDialogoEdicion(BuildContext context, NumeroSerie serie) {
    final serialController = TextEditingController(text: serie.codigoSerial);
    String estadoSeleccionado = serie.estado;
    final estadosPosibles = ['DISPONIBLE', 'VENDIDO', 'DAÑADO', 'PERDIDO'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Editar Número de Serie', style: TextStyle(color: AppColors.textPrimary)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: serialController,
                  decoration: const InputDecoration(labelText: 'Código Serial'),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: estadoSeleccionado,
                  dropdownColor: AppColors.surface2,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: estadosPosibles.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) {
                    if (val != null) setStateDialog(() => estadoSeleccionado = val);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                onPressed: () async {
                  final serieActualizada = NumeroSerie(
                    id: serie.id,
                    productoId: serie.productoId,
                    codigoSerial: serialController.text.trim(),
                    estado: estadoSeleccionado,
                    fechaIngreso: serie.fechaIngreso,
                  );
                  await ref.read(numerosSerieProvider.notifier).actualizarNumeroSerie(serieActualizada);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _confirmarEliminacion(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('¿Eliminar Serial?', style: TextStyle(color: AppColors.error)),
        content: const Text('Esta acción no se puede deshacer. ¿Estás seguro?', style: TextStyle(color: AppColors.textPrimary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              await ref.read(numerosSerieProvider.notifier).eliminarNumeroSerie(id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(numerosSerieProvider);

    final filtrados = state.numeros.where((s) {
      return s.codigoSerial.toLowerCase().contains(_searchQuery.toLowerCase()) || 
             s.productoId.toString().contains(_searchQuery);
    }).toList();

    return Column(
      children: [
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Inventario Físico (Series)', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar por serial o ID de producto...',
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
            if (state.isLoading && state.numeros.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: AppColors.accent));
            }
            if (state.error != null && state.numeros.isEmpty) {
              return Center(child: Text(state.error!, style: const TextStyle(color: AppColors.error)));
            }
            if (filtrados.isEmpty) {
              return const Center(
                child: Text('No hay números de serie registrados.', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtrados.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final serie = filtrados[i];
                final isDisponible = serie.estado == 'DISPONIBLE';

                return Card(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
                  child: ListTile(
                    leading: const Icon(Icons.qr_code, color: AppColors.accent),
                    title: Text(serie.codigoSerial, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                    subtitle: Text('Producto ID: ${serie.productoId}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDisponible ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(serie.estado, style: TextStyle(color: isDisponible ? AppColors.success : AppColors.error, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                          color: AppColors.surface2,
                          onSelected: (val) {
                            if (val == 'editar') _mostrarDialogoEdicion(context, serie);
                            if (val == 'eliminar' && serie.id != null) _confirmarEliminacion(context, serie.id!);
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(value: 'editar', child: Text('Editar', style: TextStyle(color: AppColors.textPrimary))),
                            const PopupMenuItem(value: 'eliminar', child: Text('Eliminar', style: TextStyle(color: AppColors.error))),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}