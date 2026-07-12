// lib/presentation/navigation/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_inventario_app/presentation/screens/admin/clientes_admin_screen.dart';
import 'package:flutter_inventario_app/presentation/screens/admin/turno_caja_screen.dart';
import 'package:flutter_inventario_app/presentation/screens/admin/venta_form_screen.dart';
import 'package:flutter_inventario_app/presentation/screens/admin/venta_screen.dart';
import 'package:flutter_inventario_app/presentation/screens/admin/metodo_pago_admin_screen.dart';
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
import '../screens/admin/dashboard_screen.dart';
import '../screens/admin/categories_admin_screen.dart';
import '../screens/admin/products_admin_screen.dart';
import '../screens/admin/orders_admin_screen.dart';
import '../screens/admin/order_admin_detail_screen.dart';
import '../screens/admin/users_admin_screen.dart';
import '../screens/admin/cotizacion_admin_screen.dart';
import '../screens/admin/devolucion_cliente_admin_screen.dart';
import '../widgets/admin_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: _AuthStateListenable(ref),
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final location = state.matchedLocation;

      if (auth.isChecking) return null;

      final isAuthRoute = location == '/login' ||
          location == '/register' ||
          location == '/forgot-password' ||
          location == '/reset-password-confirm';

      if (!auth.isAuthenticated && !isAuthRoute) return '/login';
      if (auth.isAuthenticated && isAuthRoute) return '/admin';

      // ⚠️ TEMPORAL: sin zona pública todavía, cualquier usuario
      // autenticado se queda en /admin.

      return null;
    },
    routes: [
      // ── Auth ──────────────────────────────────────────────
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
          path: '/forgot-password',
          builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(
          path: '/reset-password-confirm',
          builder: (_, __) => const ResetPasswordConfirmScreen()),

      // ── Staff ─────────────────────────────────────────────
      GoRoute(
          path: '/send-notification',
          builder: (_, __) => const SendNotificationScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),

      // ── Admin ─────────────────────────────────────────────
      GoRoute(
        path: '/admin',
        builder: (_, s) => AdminShell(
          title: 'Dashboard',
          currentRoute: s.matchedLocation,
          child: const DashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/categories',
        builder: (_, s) => AdminShell(
          title: 'Categorías',
          currentRoute: s.matchedLocation,
          child: const CategoriesAdminScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/products',
        builder: (_, s) => AdminShell(
          title: 'Productos',
          currentRoute: s.matchedLocation,
          child: const ProductsAdminScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/orders',
        builder: (_, s) => AdminShell(
          title: 'Pedidos',
          currentRoute: s.matchedLocation,
          child: const OrdersAdminScreen(),
        ),
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, s) => OrderAdminDetailScreen(
              orderId: int.parse(s.pathParameters['id']!),
            ),
          ),
        ],
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
        path:    '/admin/users',
        builder: (_, s) => AdminShell(
          title: 'Usuarios',
          currentRoute: s.matchedLocation,
          child: const UsersAdminScreen(),
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