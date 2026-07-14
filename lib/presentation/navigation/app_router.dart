// lib/presentation/navigation/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_inventario_app/presentation/screens/admin/ajustes_inventario_admin_screen.dart';
import 'package:flutter_inventario_app/presentation/screens/admin/categorias_admin_screen.dart';
import 'package:flutter_inventario_app/presentation/screens/admin/clientes_admin_screen.dart';
import 'package:flutter_inventario_app/presentation/screens/admin/cotizacion_admin_screen.dart';
import 'package:flutter_inventario_app/presentation/screens/admin/crear_traslado_screen.dart';
import 'package:flutter_inventario_app/presentation/screens/admin/devolucion_cliente_admin_screen.dart';
import 'package:flutter_inventario_app/presentation/screens/admin/metodo_pago_admin_screen.dart';
import 'package:flutter_inventario_app/presentation/screens/admin/movimientos_inventario_admin_screen.dart';
import 'package:flutter_inventario_app/presentation/screens/admin/numeros_serie_admin_screen.dart';
import 'package:flutter_inventario_app/presentation/screens/admin/orden_compra_detail_screen.dart';
import 'package:flutter_inventario_app/presentation/screens/admin/ordenes_compra_admin_screen.dart';
import 'package:flutter_inventario_app/presentation/screens/admin/productos_admin_screen.dart';
import 'package:flutter_inventario_app/presentation/screens/admin/proveedores_admin_screen.dart';
import 'package:flutter_inventario_app/presentation/screens/admin/traslados_bodega_admin_screen.dart';
import 'package:flutter_inventario_app/presentation/screens/admin/turno_caja_screen.dart';
import 'package:flutter_inventario_app/presentation/screens/admin/unidades_medida_admin_screen.dart';
import 'package:flutter_inventario_app/presentation/screens/admin/venta_form_screen.dart';
import 'package:flutter_inventario_app/presentation/screens/admin/venta_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/model/auth_state.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/profile_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/reset_password_confirm_screen.dart';
import '../screens/admin/send_notification_screen.dart';
import '../screens/catalog/catalog_screen.dart';
import '../screens/catalog/home_screen.dart';
import '../screens/catalog/product_detail_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/orders/order_detail_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/admin/dashboard_screen.dart';
import '../screens/admin/categories_admin_screen.dart';
import '../screens/admin/order_admin_detail_screen.dart';
import '../screens/admin/orders_admin_screen.dart';
import '../screens/admin/products_admin_screen.dart';
import '../screens/admin/users_admin_screen.dart';
import '../screens/admin/marcas_admin_screen.dart';
import '../widgets/admin_shell.dart';
import '../screens/admin/bodegas_admin_screen.dart';
import '../screens/admin/ubicaciones_admin_screen.dart';
import '../screens/admin/stock_bodegas_admin_screen.dart';
import '../screens/admin/alertas_stock_admin_screen.dart';
import 'public_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: _AuthStateListenable(ref),
    redirect: (context, state) {
      final auth     = ref.read(authProvider);
      final location = state.matchedLocation;

      if (auth.isChecking) return null;

      final isAuthRoute = location == '/login'
          || location == '/register'
          || location == '/forgot-password'
          || location == '/reset-password-confirm';

      if (!auth.isAuthenticated && !isAuthRoute) return '/login';
      if ( auth.isAuthenticated &&  isAuthRoute) return auth.isStaff ? '/admin' : '/';
      if ( auth.isAuthenticated && !auth.isStaff && location.startsWith('/admin')) return '/';
      if ( auth.isAuthenticated && !auth.isStaff && location == '/send-notification') return '/';

      return null;
    },
    routes: [
      // ── Auth ──────────────────────────────────────────────
      GoRoute(path: '/login',    builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot-password',        builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/reset-password-confirm', builder: (_, __) => const ResetPasswordConfirmScreen()),
      

      // ── Zona pública con BottomNavBar ──────────────────────
      ShellRoute(
        builder: (_, __, child) => PublicShell(child: child),
        routes: [
          GoRoute(path: '/',       builder: (_, __) => const CatalogScreen()),
          GoRoute(
            path: '/catalog',
            builder: (_, __) => const CatalogScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, s) => ProductDetailScreen(
                  productId: int.parse(s.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(path: '/cart',    builder: (_, __) => const CartScreen()),
          GoRoute(path: '/orders',  builder: (_, __) => const OrdersScreen()),
          GoRoute(
            path:    '/orders/:id',
            builder: (_, s) => OrderDetailScreen(
              orderId: int.parse(s.pathParameters['id']!),
            ),
          ),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // ── Admin ─────────────────────────────────────────────
      GoRoute(
        path:    '/admin',
        builder: (_, s) => AdminShell(
          title:        'Productos',
          currentRoute: s.matchedLocation,
          child:        const ProductosAdminScreen(),
        ),
      ),
      GoRoute(
        path:    '/admin/categories',
        builder: (_, s) => AdminShell(
          title:        'Categorías',
          currentRoute: s.matchedLocation,
          child:        const CategoriesAdminScreen(),
        ),
      ),
      GoRoute(
        path:    '/admin/products',
        builder: (_, s) => AdminShell(
          title:        'Productos',
          currentRoute: s.matchedLocation,
          child:        const ProductsAdminScreen(),
        ),
      ),
      GoRoute(
        path:    '/admin/orders',
        builder: (_, s) => AdminShell(
          title:        'Pedidos',
          currentRoute: s.matchedLocation,
          child:        const OrdersAdminScreen(),
        ),
      ),
      GoRoute(
        path:    '/admin/orders/:id',
        builder: (_, s) => AdminShell(
          title:        'Detalle pedido #${s.pathParameters['id']}',
          currentRoute: '/admin/orders',
          child:        OrderAdminDetailScreen(
            orderId: int.parse(s.pathParameters['id']!),
          ),
        ),
      ),
      GoRoute(
        path:    '/admin/users',
        builder: (_, s) => AdminShell(
          title:        'Usuarios',
          currentRoute: s.matchedLocation,
          child:        const UsersAdminScreen(),
        ),
      ),

       GoRoute(
        path: '/admin/clientes',
        builder: (_, s) => AdminShell(
          title: 'Clientes',
          currentRoute: s.matchedLocation,
          child: const ClientesAdminScreen(),
        ),
      ),
      
      GoRoute(
        path: '/admin/turno-caja',
        builder: (_, s) => AdminShell(
          title: 'Turno de Caja',
          currentRoute: s.matchedLocation,
          child: const TurnoCajaScreen(),
        ),
      ),

      GoRoute(
        path: '/admin/venta',
        builder: (_, s) => AdminShell(
          title: 'Registrar Venta',
          currentRoute: s.matchedLocation,
          child: const VentaScreen(),
        ),
      ),
      
      GoRoute(
        path: '/admin/ventas',
        builder: (_, s) => AdminShell(
          title: 'Historial de Ventas',
          currentRoute: s.matchedLocation,
          child: const VentasAdminScreen(),
        ),
      ),
      
      GoRoute(
        path: '/admin/metodos-pago',
        builder: (_, s) => AdminShell(
          title: 'Métodos de Pago',
          currentRoute: s.matchedLocation,
          child: const MetodoPagoAdminScreen(),
        ),
      ),

      GoRoute(
        path:    '/admin/cotizaciones',
        builder: (_, s) => AdminShell(
          title:        'Cotizaciones',
          currentRoute: s.matchedLocation,
          child:        const CotizacionAdminScreen(),
        ),
      ),

      GoRoute(
        path:    '/admin/devoluciones',
        builder: (_, s) => AdminShell(
          title:        'Devoluciones',
          currentRoute: s.matchedLocation,
          child:        const DevolucionClienteAdminScreen(),
        ),
      ),

      GoRoute(
        path:   '/admin/proveedores',
        builder: (_, s) => AdminShell(
          title:        'Proveedores',
          currentRoute: s.matchedLocation,
          child:        const ProveedoresAdminScreen(),
        ),
      ),

      GoRoute(
        path:    '/admin/ordenes-compra',
        builder: (_, s) => AdminShell(
          title:        'Compras a Proveedores',
          currentRoute: s.matchedLocation,
          child:        const OrdenesCompraAdminScreen(),
        ),
      ),
      
      GoRoute(
        path:    '/admin/ordenes-compra/:id',
        builder: (_, s) => AdminShell(
          title:        'Detalle Orden #${s.pathParameters['id']}',
          currentRoute: '/admin/ordenes-compra',
          child:        OrdenCompraDetailScreen(
            orderId: int.parse(s.pathParameters['id']!),
          ),
        ),
      ),

      GoRoute(
        path:    '/admin/series',
        builder: (_, s) => AdminShell(
          title:        'Control de Seriales',
          currentRoute: s.matchedLocation,
          child:        const NumerosSerieAdminScreen(),
        ),
      ),

      GoRoute(
        path: '/admin/movimientos',
        builder: (_, s) => AdminShell(
          title: 'Movimientos',
          currentRoute: s.matchedLocation,
          child: const MovimientosInventarioAdminScreen(),
        ),
      ),
      
      GoRoute(
        path: '/admin/ajustes',
        builder: (_, s) => AdminShell(
          title: 'Ajustes de Inventario',
          currentRoute: s.matchedLocation,
          child: const AjustesInventarioAdminScreen(),
        ),
      ),

      GoRoute(
        path: '/admin/traslados',
        builder: (_, s) => AdminShell(
          title: 'Traslados de Bodega',
          currentRoute: s.matchedLocation,
          child: const TrasladosBodegaAdminScreen(),
        ),
      ),
      
      GoRoute(
        path: '/admin/traslados/nuevo',
        // SIN el AdminShell porque es una pantalla completa que se apila encima
        builder: (_, __) => const CrearTrasladoScreen(),
      ),

      GoRoute(
        path: '/admin/marcas',
        builder: (_, s) => AdminShell(
          title: 'Marcas',
          currentRoute: s.matchedLocation,
          child: const MarcasAdminScreen(),
        ),
      ),

      GoRoute(
        path: '/admin/categorias',
        builder: (_, s) => AdminShell(
          title: 'Categorías',
          currentRoute: s.matchedLocation,
          child: const CategoriasAdminScreen(),
        ),
      ),

      GoRoute(
        path: '/admin/unidades',
        builder: (_, s) => AdminShell(
          title: 'Unidades de Medida',
          currentRoute: s.matchedLocation,
          child: const UnidadesMedidaAdminScreen(),
        ),
      ),
      
      GoRoute(
        path: '/admin/productos',
        builder: (_, s) => AdminShell(
          title: 'Productos',
          currentRoute: s.matchedLocation,
          child: const ProductosAdminScreen(),
        ),
      ),
    ],
  );
});

class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }
}