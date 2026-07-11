// lib/presentation/navigation/public_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/cart_provider.dart';
import '../../theme/app_colors.dart';

class PublicShell extends ConsumerWidget {
  final Widget child;
  final bool   showCart;
  
  const PublicShell({super.key, required this.child, this.showCart = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount   = ref.watch(cartProvider).totalItems;
    final location    = GoRouterState.of(context).matchedLocation;

    int _selectedIndex() {
      if (location.startsWith('/catalog')) return 1;
      if (location.startsWith('/orders'))  return 2;
      if (location.startsWith('/cart'))    return 3;
      if (location.startsWith('/profile')) return 4;
      return 0;
    }

    return Scaffold(
      body: child,
      // Aplicamos el color de fondo general de tu app
      backgroundColor: AppColors.background, 
      bottomNavigationBar: Container(
        // Añadimos un sutil borde superior para separar el contenido de la barra
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.cardBackground, width: 1.0),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex(),
          type:         BottomNavigationBarType.fixed,
          // ── Inyección de tu paleta de colores ──
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.primary, // Tu morado (#A83DE8)
          unselectedItemColor: AppColors.iconGray, // Tu gris (#8E8E93)
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          
          items: [
            const BottomNavigationBarItem(
              icon:  Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            const BottomNavigationBarItem(
              icon:  Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view),
              label: 'Catálogo',
            ),
            const BottomNavigationBarItem(
              icon:  Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Pedidos',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart_outlined),
                  if (cartCount > 0 && showCart)
                    Positioned(
                      right: -6,
                      top:   -4,
                      child: Container(
                        padding:    const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error, // Rojo para alertas
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          cartCount > 99 ? '99+' : cartCount.toString(),
                          style: const TextStyle(
                            color:    AppColors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              activeIcon: const Icon(Icons.shopping_cart),
              label: 'Carrito',
            ),
            const BottomNavigationBarItem(
              icon:  Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
          onTap: (index) {
            switch (index) {
              case 0: context.go('/');        break;
              case 1: context.go('/catalog'); break;
              case 2: context.go('/orders');  break;
              case 3: context.go('/cart');    break;
              case 4: context.go('/profile'); break;
            }
          },
        ),
      ),
    );
  }
}