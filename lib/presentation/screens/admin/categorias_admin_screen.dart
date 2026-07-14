// lib/presentation/screens/admin/categorias_admin_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../providers/categoria_provider.dart';
import '../../widgets/categoria_form.dart';

class CategoriasAdminScreen extends ConsumerStatefulWidget {
  const CategoriasAdminScreen({super.key});

  @override
  ConsumerState<CategoriasAdminScreen> createState() => _CategoriasAdminScreenState();
}

class _CategoriasAdminScreenState extends ConsumerState<CategoriasAdminScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoriasProvider.notifier).cargarCategorias();
    });
  }

  void _confirmarEliminar(BuildContext context, int id, String nombre) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar Categoría', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('¿Estás seguro de que deseas eliminar "$nombre"?', style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(categoriasProvider.notifier).eliminarCategoria(id);
              if (!success && mounted) {
                final error = ref.read(categoriasProvider).error;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Error al eliminar'), backgroundColor: AppColors.error));
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
    final state = ref.watch(categoriasProvider);

    final filtradas = state.categorias.where((c) {
      final query = _searchQuery.toLowerCase();
      return c.nombre.toLowerCase().contains(query) || c.descripcion.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCategoriaForm(context, ref),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add, color: AppColors.onAccent),
        label: const Text('Nueva Categoría', style: TextStyle(color: AppColors.onAccent, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Gestión de Categorías', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar categoría...',
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
              if (state.isLoading && state.categorias.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppColors.accent));
              }
              if (state.error != null && state.categorias.isEmpty) {
                return Center(child: Text(state.error!, style: const TextStyle(color: AppColors.error)));
              }
              if (filtradas.isEmpty) {
                return const Center(child: Text('No hay categorías registradas.', style: TextStyle(color: AppColors.textSecondary)));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16).copyWith(bottom: 80),
                itemCount: filtradas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final categoria = filtradas[i];
                  return Card(
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: categoria.activa ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                        child: Icon(
                          categoria.activa ? Icons.check_circle_outline : Icons.cancel_outlined,
                          color: categoria.activa ? AppColors.success : AppColors.error,
                        ),
                      ),
                      title: Text(categoria.nombre, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(categoria.descripcion.isNotEmpty ? categoria.descripcion : 'Sin descripción', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text('Productos: ${categoria.totalProductos ?? 0}', style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                            onPressed: () => showCategoriaForm(context, ref, categoriaAEditar: categoria),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            onPressed: () => _confirmarEliminar(context, categoria.id!, categoria.nombre),
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