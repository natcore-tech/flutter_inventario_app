// lib/presentation/providers/admin/metodo_pago_admin_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/remote/api/metodo_pago_remote_datasource.dart';
import '../../domain/model/metodo_pago.dart';

class MetodoPagoAdminState {
  final List<MetodoPago> metodos;
  final bool             isLoading;
  final String?          error;
  final String           search;
  final MetodoPagoFormState formState;

  const MetodoPagoAdminState({
    this.metodos   = const [],
    this.isLoading = false,
    this.error,
    this.search    = '',
    this.formState = const MetodoPagoFormIdle(),
  });

  List<MetodoPago> get filtered => search.isEmpty
      ? metodos
      : metodos.where((m) => m.nombre.toLowerCase().contains(search.toLowerCase())).toList();

  MetodoPagoAdminState copyWith({
    List<MetodoPago>? metodos,
    bool?    isLoading,
    String?  error,
    String?  search,
    MetodoPagoFormState? formState,
  }) => MetodoPagoAdminState(
    metodos:   metodos   ?? this.metodos,
    isLoading: isLoading ?? this.isLoading,
    error:     error,
    search:    search    ?? this.search,
    formState: formState ?? this.formState,
  );
}

sealed class MetodoPagoFormState { const MetodoPagoFormState(); }
class MetodoPagoFormIdle    extends MetodoPagoFormState { const MetodoPagoFormIdle(); }
class MetodoPagoFormSaving  extends MetodoPagoFormState { const MetodoPagoFormSaving(); }
class MetodoPagoFormSuccess extends MetodoPagoFormState {
  final String message;
  const MetodoPagoFormSuccess(this.message);
}
class MetodoPagoFormError extends MetodoPagoFormState {
  final String message;
  const MetodoPagoFormError(this.message);
}

class MetodoPagoAdminNotifier extends StateNotifier<MetodoPagoAdminState> {
  final MetodoPagoRemoteDatasource _datasource;

  MetodoPagoAdminNotifier(this._datasource) : super(const MetodoPagoAdminState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _datasource.getMetodosPago();
      state = state.copyWith(metodos: result, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void setSearch(String q) => state = state.copyWith(search: q);

  // Toggle optimista de activo/inactivo
  Future<void> toggleActivo(int id, bool esActivo) async {
    state = state.copyWith(
      metodos: state.metodos.map((m) =>
        m.id == id ? MetodoPago(id: m.id, nombre: m.nombre, esActivo: esActivo) : m,
      ).toList(),
    );
    try {
      await _datasource.updateMetodoPago(id, {'es_activo': esActivo});
    } catch (_) {
      state = state.copyWith(
        metodos: state.metodos.map((m) =>
          m.id == id ? MetodoPago(id: m.id, nombre: m.nombre, esActivo: !esActivo) : m,
        ).toList(),
      );
    }
  }

  Future<void> createMetodoPago(String nombre) async {
    state = state.copyWith(formState: const MetodoPagoFormSaving());
    try {
      final created = await _datasource.createMetodoPago({'nombre': nombre});
      state = state.copyWith(
        metodos: [created, ...state.metodos],
        formState: const MetodoPagoFormSuccess('Método de pago creado'),
      );
    } catch (e) {
      state = state.copyWith(
        formState: MetodoPagoFormError(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  Future<void> updateMetodoPago(int id, String nombre) async {
    state = state.copyWith(formState: const MetodoPagoFormSaving());
    try {
      final updated = await _datasource.updateMetodoPago(id, {'nombre': nombre});
      state = state.copyWith(
        metodos: state.metodos.map((m) => m.id == id ? updated : m).toList(),
        formState: const MetodoPagoFormSuccess('Método de pago actualizado'),
      );
    } catch (e) {
      state = state.copyWith(
        formState: MetodoPagoFormError(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  Future<void> deleteMetodoPago(int id) async {
    try {
      await _datasource.deleteMetodoPago(id);
      state = state.copyWith(
        metodos: state.metodos.where((m) => m.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString().replaceAll('Exception: ', ''));
    }
  }

  void resetFormState() => state = state.copyWith(formState: const MetodoPagoFormIdle());
}

final metodoPagoAdminProvider =
    StateNotifierProvider<MetodoPagoAdminNotifier, MetodoPagoAdminState>((ref) {
  return MetodoPagoAdminNotifier(ref.watch(metodoPagoDatasourceProvider));
});