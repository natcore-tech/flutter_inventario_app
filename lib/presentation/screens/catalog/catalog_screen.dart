// lib/presentation/screens/catalog/catalog_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../providers/public_catalog_provider.dart';

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogState = ref.watch(publicCatalogProvider);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surface2,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Catálogo Completo',
          style: tt.titleLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Builder(
        builder: (context) {
          if (catalogState.isLoading && catalogState.productos.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accent));
          }

          if (catalogState.error != null && catalogState.productos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                  const SizedBox(height: 16),
                  Text(catalogState.error!, style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.read(publicCatalogProvider.notifier).cargarDisponibles(),
                    child: const Text('Reintentar'),
                  )
                ],
              ),
            );
          }

          if (catalogState.productos.isEmpty) {
            return const Center(
              child: Text('No hay productos disponibles por el momento.', style: TextStyle(color: AppColors.textSecondary)),
            );
          }

          return RefreshIndicator(
            color: AppColors.accent,
            onRefresh: () => ref.read(publicCatalogProvider.notifier).cargarDisponibles(),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65, // Ajustado ligeramente para dar espacio al botón
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: catalogState.productos.length,
              itemBuilder: (context, index) {
                final producto = catalogState.productos[index];
                
                return Card(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Espacio de la Imagen
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          color: AppColors.accent.withValues(alpha: 0.1),
                          child: const Icon(Icons.image_outlined, size: 48, color: AppColors.accent),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              producto.nombre,
                              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${producto.precio.toStringAsFixed(2)}',
                              style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: AppColors.onAccent,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${producto.nombre} añadido al carrito'),
                                      backgroundColor: AppColors.success,
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: const Text('Agregar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}