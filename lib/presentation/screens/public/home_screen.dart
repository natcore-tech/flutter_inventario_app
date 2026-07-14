// lib/presentation/screens/public/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../providers/public_catalog_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogState = ref.watch(publicCatalogProvider);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Fondo oscuro
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                RichText(
                  text: TextSpan(
                    style: tt.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    children: const [
                      TextSpan(text: 'Descubre lo\n'),
                      TextSpan(
                        text: 'extraordinario',
                        style: TextStyle(color: AppColors.accent),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                Text(
                  'Los mejores productos seleccionados para ti.',
                  style: tt.bodyLarge?.copyWith(color: Colors.grey[400]),
                ),
                const SizedBox(height: 24),
                
                ElevatedButton.icon(
                  onPressed: () => context.go('/catalog'),
                  icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
                  label: const Text(
                    'Ver catálogo',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 48),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Novedades',
                      style: tt.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => context.go('/catalog'),
                      child: const Text('Ver todos', style: TextStyle(color: AppColors.accent)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                SizedBox(
                  height: 220,
                  child: Builder(builder: (_) {
                    if (catalogState.isLoading && catalogState.productos.isEmpty) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
                    }
                    if (catalogState.productos.isEmpty) {
                      return const Center(
                        child: Text('No hay novedades.', style: TextStyle(color: Colors.grey)),
                      );
                    }

                    final novedades = catalogState.productos.take(5).toList();

                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: novedades.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final prod = novedades[index];
                        return Container(
                          width: 150,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2C),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF383838),
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                  ),
                                  child: const Icon(Icons.image_outlined, color: Colors.grey, size: 40),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      prod.nombre,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${prod.precio.toStringAsFixed(2)}',
                                      style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}