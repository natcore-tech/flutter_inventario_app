// lib/presentation/providers/admin/cotizacion_admin_provider.dart
import 'package:flutter_inventario_app/presentation/domain/model/cotizacion.dart';
import 'package:flutter_inventario_app/presentation/domain/model/producto_lite.dart';
import 'package:flutter_inventario_app/presentation/domain/model/proveedor_lite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/remote/api/cotizacion_remote_datasource.dart';
import '../../../data/remote/api/proveedor_lite_remote_datasource.dart';
import '../../../data/remote/api/producto_lite_remote_datasource.dart';

// ── Datos de apoyo para el selector de proveedor ────────────────
final proveedoresListProvider = FutureProvider<List<ProveedorLite>>((ref) {
  return ref.watch(proveedorLiteDatasourceProvider).getProveedores();
});

// ── Datos de apoyo para buscar productos a cotizar ──────────────
// (definido aquí, NO en venta_provider.dart, para que esta rama
// (feature/gestion-comercial) no dependa de feature/facturacion-pos)
final productosSearchProvider =
    FutureProvider.family<List<ProductoLite>, String>((ref, query) {
  return ref.watch(productoLiteDatasourceProvider).getProductos(search: query);
});

class CotizacionAdminState {
  final List<Cotizacion> cotizaciones;
  final bool             isLoading;
  final String?          error;
  final String           search;
  final CotizacionFormState formState;

  const CotizacionAdminState({
    this.cotizaciones = const [],
    this.isLoading    = false,
    this.error,
    this.search        = '',
    this.formState     = const CotizacionFormIdle(),
  });

  List<Cotizacion> get filtered => search.isEmpty
      ? cotizaciones
      : cotizaciones.where((c) =>
          c.codigoCotizacion.toLowerCase().contains(search.toLowerCase())).toList();

  CotizacionAdminState copyWith({
    List<Cotizacion>? cotizaciones,
    bool?    isLoading,
    String?  error,
    String?  search,
    CotizacionFormState? formState,
  }) => CotizacionAdminState(
    cotizaciones: cotizaciones ?? this.cotizaciones,
    isLoading:    isLoading    ?? this.isLoading,
    error:        error,
    search:       search       ?? this.search,
    formState:    formState    ?? this.formState,
  );
}

sealed class CotizacionFormState { const CotizacionFormState(); }
class CotizacionFormIdle    extends CotizacionFormState { const CotizacionFormIdle(); }
class CotizacionFormSaving  extends CotizacionFormState { const CotizacionFormSaving(); }
class CotizacionFormSuccess extends CotizacionFormState {
  final String message;
  const CotizacionFormSuccess(this.message);
}
class CotizacionFormError extends CotizacionFormState {
  final String message;
  const CotizacionFormError(this.message);
}

class CotizacionAdminNotifier extends StateNotifier<CotizacionAdminState> {
  final CotizacionRemoteDatasource _datasource;

  CotizacionAdminNotifier(this._datasource) : super(const CotizacionAdminState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _datasource.getCotizaciones();
      state = state.copyWith(cotizaciones: result, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void setSearch(String q) => state = state.copyWith(search: q);

  Future<void> crearCotizacion({
    required int proveedorId,
    required String codigoCotizacion,
    required DateTime fechaValidez,
    required double totalPropuesto,
    required List<CotizacionDetalle> detalles,
  }) async {
    state = state.copyWith(formState: const CotizacionFormSaving());
    try {
      final creada = await _datasource.crearCotizacion(
        proveedorId:      proveedorId,
        codigoCotizacion: codigoCotizacion,
        fechaValidez:     fechaValidez,
        totalPropuesto:   totalPropuesto,
        detalles:         detalles,
      );
      state = state.copyWith(
        cotizaciones: [creada, ...state.cotizaciones],
        formState: const CotizacionFormSuccess('Cotización creada correctamente'),
      );
    } catch (e) {
      state = state.copyWith(
        formState: CotizacionFormError(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  Future<void> deleteCotizacion(int id) async {
    try {
      await _datasource.deleteCotizacion(id);
      state = state.copyWith(
        cotizaciones: state.cotizaciones.where((c) => c.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString().replaceAll('Exception: ', ''));
    }
  }

  void resetFormState() => state = state.copyWith(formState: const CotizacionFormIdle());
}

final cotizacionAdminProvider =
    StateNotifierProvider<CotizacionAdminNotifier, CotizacionAdminState>((ref) {
  return CotizacionAdminNotifier(ref.watch(cotizacionDatasourceProvider));
});