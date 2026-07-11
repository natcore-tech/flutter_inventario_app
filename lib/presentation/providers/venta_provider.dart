// lib/presentation/providers/admin/venta_provider.dart

import 'package:flutter_inventario_app/presentation/domain/model/cliente.dart';
import 'package:flutter_inventario_app/presentation/domain/model/venta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/remote/api/venta_remote_datasource.dart';
import '../../../data/remote/api/cliente_remote_datasource.dart';
import '../../../data/remote/api/producto_lite_remote_datasource.dart';
import '../../../data/remote/api/metodo_pago_remote_datasource.dart';
import '../../domain/model/producto_lite.dart';
import '../../domain/model/metodo_pago.dart';

// ── Datos de apoyo para poblar los selectores de la pantalla ────

final clientesListProvider = FutureProvider<List<Cliente>>((ref) {
  return ref.watch(clienteDatasourceProvider).getClientes();
});

final productosSearchProvider =
    FutureProvider.family<List<ProductoLite>, String>((ref, query) {
  return ref.watch(productoLiteDatasourceProvider).getProductos(search: query);
});

final metodosPagoListProvider = FutureProvider<List<MetodoPago>>((ref) {
  return ref.watch(metodoPagoDatasourceProvider).getMetodosPago();
});


class CartItem {
  final ProductoLite producto;
  final int          cantidad;
  const CartItem({required this.producto, required this.cantidad});

  double get subtotalEstimado => producto.precio * cantidad;

  CartItem copyWith({int? cantidad}) =>
      CartItem(producto: producto, cantidad: cantidad ?? this.cantidad);
}

class PagoDraft {
  final int    metodoPagoId;
  final String nombreMetodo;
  final double monto;
  const PagoDraft({
    required this.metodoPagoId,
    required this.nombreMetodo,
    required this.monto,
  });
}

class VentaCartState {
  final int?    clienteId;
  final String? nombreCliente;
  final List<CartItem> items;
  final List<PagoDraft> pagos;
  final bool    isSubmitting;
  final String? error;
  final Venta?  ultimaVentaConfirmada;

  const VentaCartState({
    this.clienteId,
    this.nombreCliente,
    this.items = const [],
    this.pagos = const [],
    this.isSubmitting = false,
    this.error,
    this.ultimaVentaConfirmada,
  });

  /// Suma estimada en el cliente (el total real con IVA/promos lo confirma el backend).
  double get subtotalEstimado =>
      items.fold(0.0, (sum, it) => sum + it.subtotalEstimado);

  double get totalPagosIngresados =>
      pagos.fold(0.0, (sum, p) => sum + p.monto);

  VentaCartState copyWith({
    int?     clienteId,
    String?  nombreCliente,
    List<CartItem>? items,
    List<PagoDraft>? pagos,
    bool?    isSubmitting,
    String?  error,
    bool     clearError = false,
    Venta?   ultimaVentaConfirmada,
    bool     clearVenta = false,
  }) => VentaCartState(
    clienteId:     clienteId     ?? this.clienteId,
    nombreCliente: nombreCliente ?? this.nombreCliente,
    items:         items         ?? this.items,
    pagos:         pagos         ?? this.pagos,
    isSubmitting:  isSubmitting  ?? this.isSubmitting,
    error:         clearError ? null : (error ?? this.error),
    ultimaVentaConfirmada:
        clearVenta ? null : (ultimaVentaConfirmada ?? this.ultimaVentaConfirmada),
  );
}

class VentaCartNotifier extends StateNotifier<VentaCartState> {
  final VentaRemoteDatasource _datasource;
  VentaCartNotifier(this._datasource) : super(const VentaCartState());

  void seleccionarCliente(int id, String nombre) {
    state = state.copyWith(clienteId: id, nombreCliente: nombre);
  }

  void agregarProducto(ProductoLite producto) {
    final idx = state.items.indexWhere((it) => it.producto.id == producto.id);
    if (idx >= 0) {
      final actualizado = List<CartItem>.from(state.items);
      final nuevaCantidad = actualizado[idx].cantidad + 1;
      if (nuevaCantidad > producto.stock) return; // no exceder stock
      actualizado[idx] = actualizado[idx].copyWith(cantidad: nuevaCantidad);
      state = state.copyWith(items: actualizado);
    } else {
      if (producto.stock < 1) return;
      state = state.copyWith(items: [...state.items, CartItem(producto: producto, cantidad: 1)]);
    }
  }

  void cambiarCantidad(int productoId, int cantidad) {
    if (cantidad <= 0) {
      quitarProducto(productoId);
      return;
    }
    state = state.copyWith(
      items: state.items.map((it) =>
        it.producto.id == productoId ? it.copyWith(cantidad: cantidad) : it,
      ).toList(),
    );
  }

  void quitarProducto(int productoId) {
    state = state.copyWith(
      items: state.items.where((it) => it.producto.id != productoId).toList(),
    );
  }

  void agregarPago(int metodoPagoId, String nombreMetodo, double monto) {
    state = state.copyWith(pagos: [
      ...state.pagos,
      PagoDraft(metodoPagoId: metodoPagoId, nombreMetodo: nombreMetodo, monto: monto),
    ]);
  }

  void quitarPago(int index) {
    final actualizado = List<PagoDraft>.from(state.pagos)..removeAt(index);
    state = state.copyWith(pagos: actualizado);
  }

  Future<bool> confirmarVenta() async {
    if (state.clienteId == null) {
      state = state.copyWith(error: 'Selecciona un cliente', clearError: false);
      return false;
    }
    if (state.items.isEmpty) {
      state = state.copyWith(error: 'Agrega al menos un producto');
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final detalles = state.items.map((it) => VentaDetalle(
            productoId: it.producto.id,
            cantidad:   it.cantidad,
          )).toList();

      final pagos = state.pagos.map((p) => PagoVenta(
            metodoPagoId: p.metodoPagoId,
            monto:        p.monto,
          )).toList();

      final venta = await _datasource.crearVenta(
        clienteId: state.clienteId!,
        detalles:  detalles,
        pagos:     pagos,
      );

      state = VentaCartState(ultimaVentaConfirmada: venta); // limpia el carrito
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void reset() => state = const VentaCartState();
}

final ventaCartProvider =
    StateNotifierProvider<VentaCartNotifier, VentaCartState>((ref) {
  return VentaCartNotifier(ref.watch(ventaDatasourceProvider));
}); 