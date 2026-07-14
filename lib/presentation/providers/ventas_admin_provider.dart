// lib/presentation/providers/admin/ventas_admin_provider.dart
import 'package:flutter_inventario_app/presentation/domain/model/venta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/remote/api/venta_remote_datasource.dart';

class VentasAdminState {
  final List<Venta> ventas;
  final bool         isLoading;
  final String?      error;
  final String       search;
  final int?         anulandoId; // id de la venta que se está anulando (para spinner puntual)

  const VentasAdminState({
    this.ventas = const [],
    this.isLoading = false,
    this.error,
    this.search = '',
    this.anulandoId,
  });

  List<Venta> get filtered => search.isEmpty
      ? ventas
      : ventas.where((v) =>
          v.nombreCliente.toLowerCase().contains(search.toLowerCase()) ||
          '${v.id}' == search.trim()).toList();

  VentasAdminState copyWith({
    List<Venta>? ventas,
    bool?        isLoading,
    String?      error,
    String?      search,
    int?         anulandoId,
    bool         clearAnulando = false,
  }) => VentasAdminState(
    ventas:     ventas    ?? this.ventas,
    isLoading:  isLoading ?? this.isLoading,
    error:      error,
    search:     search    ?? this.search,
    anulandoId: clearAnulando ? null : (anulandoId ?? this.anulandoId),
  );
}

class VentasAdminNotifier extends StateNotifier<VentasAdminState> {
  final VentaRemoteDatasource _datasource;

  VentasAdminNotifier(this._datasource) : super(const VentasAdminState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _datasource.getVentas();
      state = state.copyWith(ventas: result, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void setSearch(String q) => state = state.copyWith(search: q);

  Future<void> anularVenta(int id) async {
    state = state.copyWith(anulandoId: id, error: null);
    try {
      final actualizada = await _datasource.anularVenta(id);
      state = state.copyWith(
        ventas: state.ventas.map((v) => v.id == id ? actualizada : v).toList(),
        clearAnulando: true,
      );
    } catch (e) {
      state = state.copyWith(
        clearAnulando: true,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}

final ventasAdminProvider =
    StateNotifierProvider<VentasAdminNotifier, VentasAdminState>((ref) {
  return VentasAdminNotifier(ref.watch(ventaDatasourceProvider));
});