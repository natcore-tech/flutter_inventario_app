// lib/presentation/providers/admin/clientes_admin_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/remote/api/cliente_remote_datasource.dart';
import '../domain/model/cliente.dart';

class ClientesAdminState {
  final List<Cliente> clientes;
  final bool isLoading;
  final String? error;
  final String search;
  final ClienteFormState formState;

  const ClientesAdminState({
    this.clientes = const [],
    this.isLoading = false,
    this.error,
    this.search = '',
    this.formState = const ClienteFormIdle(),
  });

  List<Cliente> get filtered => clientes.where((c) {
    return search.isEmpty ||
        c.nombres.toLowerCase().contains(search.toLowerCase()) ||
        c.identificacion.contains(search);
  }).toList();

  ClientesAdminState copyWith({
    List<Cliente>? clientes,
    bool? isLoading,
    String? error,
    String? search,
    ClienteFormState? formState,
  }) => ClientesAdminState(
    clientes: clientes ?? this.clientes,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    search: search ?? this.search,
    formState: formState ?? this.formState,
  );
}

// Estados del Formulario
sealed class ClienteFormState { const ClienteFormState(); }
class ClienteFormIdle extends ClienteFormState { const ClienteFormIdle(); }
class ClienteFormSaving extends ClienteFormState { const ClienteFormSaving(); }
class ClienteFormSuccess extends ClienteFormState { final String message; const ClienteFormSuccess(this.message); }
class ClienteFormError extends ClienteFormState { final String message; const ClienteFormError(this.message); }

class ClientesAdminNotifier extends StateNotifier<ClientesAdminState> {
  final ClienteRemoteDatasource _datasource;

  ClientesAdminNotifier(this._datasource) : super(const ClientesAdminState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _datasource.getClientes();
      state = state.copyWith(clientes: result, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSearch(String q) => state = state.copyWith(search: q);

  Future<void> createCliente(Map<String, dynamic> payload) async {
    state = state.copyWith(formState: const ClienteFormSaving());
    try {
      final created = await _datasource.createCliente(payload);
      state = state.copyWith(
        clientes: [created, ...state.clientes],
        formState: const ClienteFormSuccess('Cliente creado correctamente'),
      );
    } catch (e) {
      state = state.copyWith(formState: ClienteFormError(e.toString()));
    }
  }

  Future<void> updateCliente(int id, Map<String, dynamic> payload) async {
    state = state.copyWith(formState: const ClienteFormSaving());
    try {
      final updated = await _datasource.updateCliente(id, payload);
      state = state.copyWith(
        clientes: state.clientes.map((c) => c.id == id ? updated : c).toList(),
        formState: const ClienteFormSuccess('Cliente actualizado'),
      );
    } catch (e) {
      state = state.copyWith(formState: ClienteFormError(e.toString()));
    }
  }

  void resetFormState() => state = state.copyWith(formState: const ClienteFormIdle());
}

final clientesAdminProvider = StateNotifierProvider<ClientesAdminNotifier, ClientesAdminState>((ref) {
  return ClientesAdminNotifier(ref.watch(clienteDatasourceProvider));
});