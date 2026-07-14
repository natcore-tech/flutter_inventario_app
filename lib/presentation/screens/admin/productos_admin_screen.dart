// lib/presentation/screens/admin/productos_admin_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../providers/producto_provider.dart';
import '../../widgets/producto_form.dart';

class ProductosAdminScreen extends ConsumerStatefulWidget {
  const ProductosAdminScreen({super.key});

  @override
  ConsumerState<ProductosAdminScreen> createState() => _ProductosAdminScreenState();
}

class _ProductosAdminScreenState extends ConsumerState<ProductosAdminScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productosProvider.notifier).cargarProductos();
    });
  }

  void _confirmarEliminar(BuildContext context, int id, String nombre) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar Producto', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('¿Eliminar "$nombre"?', style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(productosProvider.notifier).eliminarProducto(id);
              if (!success && mounted) {
                final error = ref.read(productosProvider).error;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Error'), backgroundColor: AppColors.error));
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoReabastecer(BuildContext context, int id, String nombre) {
    final qtyCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Reabastecer: $nombre', style: const TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        content: TextField(
          controller: qtyCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Cantidad a ingresar'),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () async {
              final qty = int.tryParse(qtyCtrl.text) ?? 0;
              if (qty > 0) {
                Navigator.pop(ctx);
                await ref.read(productosProvider.notifier).reabastecerProducto(id, qty);
              }
            },
            child: const Text('Añadir Stock'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productosProvider);

    final filtrados = state.productos.where((p) {
      final q = _searchQuery.toLowerCase();
      return p.nombre.toLowerCase().contains(q) || 
             (p.categoria?.nombre.toLowerCase().contains(q) ?? false);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showProductoForm(context, ref),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add, color: AppColors.onAccent),
        label: const Text('Nuevo Producto', style: TextStyle(color: AppColors.onAccent, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por producto o categoría...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface2,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          Expanded(
            child: Builder(builder: (_) {
              if (state.isLoading && state.productos.isEmpty) return const Center(child: CircularProgressIndicator(color: AppColors.accent));
              if (state.error != null && state.productos.isEmpty) return Center(child: Text(state.error!, style: const TextStyle(color: AppColors.error)));
              if (filtrados.isEmpty) return const Center(child: Text('No hay productos.', style: TextStyle(color: AppColors.textSecondary)));

              return ListView.separated(
                padding: const EdgeInsets.all(16).copyWith(bottom: 80),
                itemCount: filtrados.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final p = filtrados[i];
                  return Card(
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.nombre, style: TextStyle(color: p.esActivo ? AppColors.textPrimary : AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(p.categoria?.nombre ?? 'Sin Categoría', style: const TextStyle(color: AppColors.accent, fontSize: 12)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text('\$${p.precio.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: p.stock > 0 ? Colors.blue.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4)
                                      ),
                                      child: Text('Stock: ${p.stock}', style: TextStyle(color: p.stock > 0 ? Colors.blue : AppColors.error, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add_shopping_cart, color: AppColors.success),
                                onPressed: () => _mostrarDialogoReabastecer(context, p.id!, p.nombre),
                                tooltip: 'Añadir Stock rápido',
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                                    onPressed: () => showProductoForm(context, ref, productoAEditar: p),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                    onPressed: () => _confirmarEliminar(context, p.id!, p.nombre),
                                  ),
                                ],
                              )
                            ],
                          )
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