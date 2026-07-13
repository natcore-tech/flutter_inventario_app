// lib/presentation/providers/numero_serie_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/numero_serie.dart';
import '../../data/remote/api/numero_serie_remote_datasource.dart';
import '../../data/remote/api/dio_client.dart';
import '../../core/error/api_exception.dart';

class NumerosSerieState {
  final List<NumeroSerie> numeros;
  final bool isLoading;
  final String? error;

  const NumerosSerieState({
    this.numeros = const [],
    this.isLoading = false,
    this.error,
  });

  NumerosSerieState copyWith({
    List<NumeroSerie>? numeros,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return NumerosSerieState(
      numeros: numeros ?? this.numeros,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class NumerosSerieNotifier extends StateNotifier<NumerosSerieState> {
  final NumeroSerieRemoteDataSource _datasource;

  NumerosSerieNotifier(this._datasource) : super(const NumerosSerieState());

  Future<void> cargarNumerosSerie({int? productoId}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final lista = await _datasource.getNumerosSerie(productoId: productoId);
      state = state.copyWith(isLoading: false, numeros: lista);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error inesperado al cargar los números de serie.');
    }
  }

  Future<bool> agregarNumeroSerie(NumeroSerie nuevoSerie) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final serieCreada = await _datasource.createNumeroSerie(nuevoSerie);
      
      state = state.copyWith(
        isLoading: false,
        numeros: [serieCreada, ...state.numeros],
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al registrar el número de serie.');
      return false;
    }
  }

  Future<bool> actualizarNumeroSerie(NumeroSerie serie) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final serieActualizada = await _datasource.updateNumeroSerie(serie);
      
      final nuevaLista = state.numeros.map((s) {
        return s.id == serie.id ? serieActualizada : s;
      }).toList();

      state = state.copyWith(isLoading: false, numeros: nuevaLista);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }

  Future<bool> eliminarNumeroSerie(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _datasource.deleteNumeroSerie(id);
      
      final nuevaLista = state.numeros.where((s) => s.id != id).toList();
      
      state = state.copyWith(isLoading: false, numeros: nuevaLista);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(clearError: true);
    }
  }
}


final numeroSerieDatasourceProvider = Provider<NumeroSerieRemoteDataSource>((ref) {
  return NumeroSerieRemoteDataSource(ref.watch(dioProvider));
});

final numerosSerieProvider = StateNotifierProvider<NumerosSerieNotifier, NumerosSerieState>((ref) {
  return NumerosSerieNotifier(ref.watch(numeroSerieDatasourceProvider));
});