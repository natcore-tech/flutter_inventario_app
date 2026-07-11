// lib/presentation/providers/admin/turno_caja_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/remote/api/turno_caja_remote_datasource.dart';
import '../../domain/model/turno_caja.dart';

class TurnoCajaState {
  final TurnoCaja? turnoActual; // null = no hay turno abierto
  final bool       isLoading;
  final String?    error;
  final TurnoCajaFormState formState;

  const TurnoCajaState({
    this.turnoActual,
    this.isLoading = false,
    this.error,
    this.formState = const TurnoCajaFormIdle(),
  });

  TurnoCajaState copyWith({
    TurnoCaja? turnoActual,
    bool clearTurno = false,
    bool? isLoading,
    String? error,
    TurnoCajaFormState? formState,
  }) => TurnoCajaState(
    turnoActual: clearTurno ? null : (turnoActual ?? this.turnoActual),
    isLoading:   isLoading  ?? this.isLoading,
    error:       error,
    formState:   formState  ?? this.formState,
  );
}

sealed class TurnoCajaFormState {
  const TurnoCajaFormState();
}
class TurnoCajaFormIdle    extends TurnoCajaFormState { const TurnoCajaFormIdle(); }
class TurnoCajaFormSaving  extends TurnoCajaFormState { const TurnoCajaFormSaving(); }
class TurnoCajaFormSuccess extends TurnoCajaFormState {
  final String message;
  const TurnoCajaFormSuccess(this.message);
}
class TurnoCajaFormError extends TurnoCajaFormState {
  final String message;
  const TurnoCajaFormError(this.message);
}

class TurnoCajaNotifier extends StateNotifier<TurnoCajaState> {
  final TurnoCajaRemoteDatasource _datasource;

  TurnoCajaNotifier(this._datasource) : super(const TurnoCajaState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final turno = await _datasource.getTurnoAbiertoActual();
      state = turno != null
          ? state.copyWith(turnoActual: turno, isLoading: false)
          : state.copyWith(clearTurno: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> abrirTurno(double montoApertura) async {
    state = state.copyWith(formState: const TurnoCajaFormSaving());
    try {
      final turno = await _datasource.abrirTurno(montoApertura);
      state = state.copyWith(
        turnoActual: turno,
        formState:   const TurnoCajaFormSuccess('Turno abierto correctamente'),
      );
    } catch (e) {
      state = state.copyWith(formState: TurnoCajaFormError(e.toString()));
    }
  }

  Future<void> cerrarTurno({
    required double montoCierre,
    String observaciones = '',
  }) async {
    final turno = state.turnoActual;
    if (turno == null) return;

    state = state.copyWith(formState: const TurnoCajaFormSaving());
    try {
      await _datasource.cerrarTurno(
        id:            turno.id,
        montoCierre:   montoCierre,
        observaciones: observaciones,
      );
      state = state.copyWith(
        clearTurno: true,
        formState:  const TurnoCajaFormSuccess('Turno cerrado correctamente'),
      );
    } catch (e) {
      state = state.copyWith(formState: TurnoCajaFormError(e.toString()));
    }
  }

  void resetFormState() =>
      state = state.copyWith(formState: const TurnoCajaFormIdle());
}

final turnoCajaProvider =
    StateNotifierProvider<TurnoCajaNotifier, TurnoCajaState>((ref) {
  return TurnoCajaNotifier(ref.watch(turnoCajaDatasourceProvider));
});