// lib/presentation/screens/admin/productos_admin_screen.dart
// TODO: pantalla mínima solo para probar Venta. Reemplazar cuando
// el compañero de Catálogo/Productos suba su versión final.

import 'package:flutter/material.dart';
import 'package:flutter_inventario_app/presentation/providers/productos_admin_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductosAdminScreen extends ConsumerWidget {
  const ProductosAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productosAdminProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Productos (prueba)')),
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