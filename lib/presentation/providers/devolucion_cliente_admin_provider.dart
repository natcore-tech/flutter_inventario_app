// lib/presentation/providers/admin/devolucion_cliente_admin_provider.dart
import 'package:flutter_inventario_app/presentation/domain/model/devolucion_cliente.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/remote/api/devolucion_cliente_remote_datasource.dart';
export 'producto_search_provider.dart' show productosSearchProvider;

class DevolucionAdminState {
  final List<DevolucionCliente> devoluciones;
  final bool    isLoading;
  final String? error;
  final DevolucionFormState formState;

  const DevolucionAdminState({
    this.devoluciones = const [],
    this.isLoading = false,
    this.error,
    this.formState = const DevolucionFormIdle(),
  });

  DevolucionAdminState copyWith({
    List<DevolucionCliente>? devoluciones,
    bool?    isLoading,
    String?  error,
    DevolucionFormState? formState,
  }) => DevolucionAdminState(
    devoluciones: devoluciones ?? this.devoluciones,
    isLoading:    isLoading    ?? this.isLoading,
    error:        error,
    formState:    formState    ?? this.formState,
  );
}

sealed class DevolucionFormState { const DevolucionFormState(); }
class DevolucionFormIdle    extends DevolucionFormState { const DevolucionFormIdle(); }
class DevolucionFormSaving  extends DevolucionFormState { const DevolucionFormSaving(); }
class DevolucionFormSuccess extends DevolucionFormState {
  final String message;
  const DevolucionFormSuccess(this.message);
}
class DevolucionFormError extends DevolucionFormState {
  final String message;
  const DevolucionFormError(this.message);
}

class DevolucionAdminNotifier extends StateNotifier<DevolucionAdminState> {
  final DevolucionClienteRemoteDatasource _datasource;

  DevolucionAdminNotifier(this._datasource) : super(const DevolucionAdminState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _datasource.getDevoluciones();
      state = state.copyWith(devoluciones: result, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> crearDevolucion({
    required int productoId,
    required String motivo,
    required int cantidad,
    required EstadoProductoDevuelto estadoProducto,
  }) async {
    state = state.copyWith(formState: const DevolucionFormSaving());
    try {
      final creada = await _datasource.createDevolucion({
        'producto':        productoId,
        'motivo':          motivo,
        'cantidad':        cantidad,
        'estado_producto': estadoProductoToString(estadoProducto),
      });
      state = state.copyWith(
        devoluciones: [creada, ...state.devoluciones],
        formState: const DevolucionFormSuccess('Devolución registrada correctamente'),
      );
    } catch (e) {
      state = state.copyWith(
        formState: DevolucionFormError(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  Future<void> deleteDevolucion(int id) async {
    try {
      await _datasource.deleteDevolucion(id);
      state = state.copyWith(
        devoluciones: state.devoluciones.where((d) => d.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString().replaceAll('Exception: ', ''));
    }
  }

  void resetFormState() => state = state.copyWith(formState: const DevolucionFormIdle());
}

final devolucionAdminProvider =
    StateNotifierProvider<DevolucionAdminNotifier, DevolucionAdminState>((ref) {
  return DevolucionAdminNotifier(ref.watch(devolucionClienteDatasourceProvider));
});