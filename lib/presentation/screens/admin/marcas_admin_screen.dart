// lib/presentation/screens/admin/marcas_admin_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../providers/marca_provider.dart';
import '../../widgets/marca_form.dart';

class MarcasAdminScreen extends ConsumerStatefulWidget {
  const MarcasAdminScreen({super.key});

  @override
  ConsumerState<MarcasAdminScreen> createState() => _MarcasAdminScreenState();
}

class _MarcasAdminScreenState extends ConsumerState<MarcasAdminScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(marcasProvider.notifier).cargarMarcas();
    });
  }

  void _confirmarEliminar(BuildContext context, int id, String nombre) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar Marca', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('¿Estás seguro de que deseas eliminar "$nombre"?', style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(marcasProvider.notifier).eliminarMarca(id);
              if (!success && mounted) {
                final error = ref.read(marcasProvider).error;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Error'), backgroundColor: AppColors.error));
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marcasProvider);

    final filtradas = state.marcas.where((m) {
      return m.nombre.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showMarcaForm(context, ref),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add, color: AppColors.onAccent),
        label: const Text('Nueva Marca', style: TextStyle(color: AppColors.onAccent, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Gestión de Marcas', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar marca...',
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
              if (state.isLoading && state.marcas.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppColors.accent));
              }
              if (state.error != null && state.marcas.isEmpty) {
                return Center(child: Text(state.error!, style: const TextStyle(color: AppColors.error)));
              }
              if (filtradas.isEmpty) {
                return const Center(child: Text('No hay marcas.', style: TextStyle(color: AppColors.textSecondary)));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16).copyWith(bottom: 80),
                itemCount: filtradas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final marca = filtradas[i];
                  return Card(
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(marca.nombre, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                            onPressed: () => showMarcaForm(context, ref, marcaAEditar: marca),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            onPressed: () => _confirmarEliminar(context, marca.id!, marca.nombre),
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
      ),
    );
  }
}