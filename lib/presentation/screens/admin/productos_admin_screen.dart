// lib/presentation/screens/admin/productos_admin_screen.dart
// TODO: pantalla mínima solo para probar Venta. Reemplazar cuando
// el compañero de Catálogo/Productos suba su versión final.

import 'package:flutter/material.dart';
import 'package:flutter_inventario_app/presentation/providers/productos_admin_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductosAdminScreen extends ConsumerWidget {
  const ProductosAdminScreen({super.key});

  void _mostrarFormulario(BuildContext context, WidgetRef ref) {
    final nombreCtrl = TextEditingController();
    final precioCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final categoriaIdCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo producto (prueba)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: precioCtrl, decoration: const InputDecoration(labelText: 'Precio'), keyboardType: TextInputType.number),
              TextField(controller: stockCtrl, decoration: const InputDecoration(labelText: 'Stock'), keyboardType: TextInputType.number),
              TextField(controller: categoriaIdCtrl, decoration: const InputDecoration(labelText: 'ID Categoría'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final payload = {
                'nombre': nombreCtrl.text,
                'descripcion': '',
                'precio': double.tryParse(precioCtrl.text) ?? 0,
                'stock': int.tryParse(stockCtrl.text) ?? 0,
                'es_activo': true,
                'categoria_id': 1,
              };
              try {
                await ref.read(productosAdminProvider.notifier).createProducto(payload);
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productosAdminProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Productos (prueba)')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(context, ref),
        child: const Icon(Icons.add),
      ),
      body: Builder(builder: (_) {
        if (state.isLoading) return const Center(child: CircularProgressIndicator());
        if (state.error != null) return Center(child: Text('Error: ${state.error}'));
        if (state.productos.isEmpty) return const Center(child: Text('No hay productos creados todavía.'));

        return ListView.builder(
          itemCount: state.productos.length,
          itemBuilder: (context, i) {
            final p = state.productos[i];
            return ListTile(
              title: Text(p.nombre),
              subtitle: Text('Stock: ${p.stock}'),
              trailing: Text('\$${p.precio.toStringAsFixed(2)}'),
            );
          },
        );
      }),
    );
  }
}