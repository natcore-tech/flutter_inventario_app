// lib/presentation/widgets/turno_caja_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../providers/turno_caja_provider.dart';

// ── Abrir turno ──────────────────────────────────────────────

Future<void> showAbrirTurnoForm(BuildContext context, WidgetRef ref) {
  ref.read(turnoCajaProvider.notifier).resetFormState();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child: const _AbrirTurnoSheet(),
    ),
  );
}

class _AbrirTurnoSheet extends ConsumerStatefulWidget {
  const _AbrirTurnoSheet();

  @override
  ConsumerState<_AbrirTurnoSheet> createState() => _AbrirTurnoSheetState();
}

class _AbrirTurnoSheetState extends ConsumerState<_AbrirTurnoSheet> {
  final _formKey   = GlobalKey<FormState>();
  final _montoCtrl = TextEditingController();

  @override
  void dispose() {
    _montoCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final monto = double.parse(_montoCtrl.text.trim().replaceAll(',', '.'));
    await ref.read(turnoCajaProvider.notifier).abrirTurno(monto);
  }

  @override
  Widget build(BuildContext context) {
    final formSt   = ref.watch(turnoCajaProvider.select((s) => s.formState));
    final isSaving = formSt is TurnoCajaFormSaving;

    if (formSt is TurnoCajaFormSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Abrir turno de caja',
              style: TextStyle(
                color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Declara el fondo inicial con el que arrancas la caja.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),

            if (formSt is TurnoCajaFormError) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  formSt.message,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),
              const SizedBox(height: 14),
            ],

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _montoCtrl,
                    enabled: !isSaving,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Fondo inicial en caja *',
                      prefixText: r'$ ',
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                    validator: (v) {
                      final err = validateRequired(v, 'Monto');
                      if (err != null) return err;
                      final n = double.tryParse(v!.trim().replaceAll(',', '.'));
                      if (n == null) return 'Ingresa un número válido';
                      if (n < 0) return 'El monto no puede ser negativo';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSaving ? null : () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSaving ? null : _submit,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                          child: isSaving
                              ? const SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: AppColors.onAccent,
                                  ),
                                )
                              : const Text('Abrir turno'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Cerrar turno ─────────────────────────────────────────────

Future<void> showCerrarTurnoForm(BuildContext context, WidgetRef ref) {
  ref.read(turnoCajaProvider.notifier).resetFormState();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child: const _CerrarTurnoSheet(),
    ),
  );
}

class _CerrarTurnoSheet extends ConsumerStatefulWidget {
  const _CerrarTurnoSheet();

  @override
  ConsumerState<_CerrarTurnoSheet> createState() => _CerrarTurnoSheetState();
}

class _CerrarTurnoSheetState extends ConsumerState<_CerrarTurnoSheet> {
  final _formKey  = GlobalKey<FormState>();
  final _montoCtrl = TextEditingController();
  final _obsCtrl   = TextEditingController();

  @override
  void dispose() {
    _montoCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final monto = double.parse(_montoCtrl.text.trim().replaceAll(',', '.'));
    await ref.read(turnoCajaProvider.notifier).cerrarTurno(
          montoCierre: monto,
          observaciones: _obsCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final turno    = ref.watch(turnoCajaProvider.select((s) => s.turnoActual));
    final formSt   = ref.watch(turnoCajaProvider.select((s) => s.formState));
    final isSaving = formSt is TurnoCajaFormSaving;

    if (formSt is TurnoCajaFormSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Cerrar turno de caja',
              style: TextStyle(
                color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            if (turno != null)
              Text(
                'Fondo inicial: \$${turno.montoApertura.toStringAsFixed(2)}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            const SizedBox(height: 20),

            if (formSt is TurnoCajaFormError) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  formSt.message,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),
              const SizedBox(height: 14),
            ],

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _montoCtrl,
                    enabled: !isSaving,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Dinero contado al cerrar *',
                      prefixText: r'$ ',
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                    validator: (v) {
                      final err = validateRequired(v, 'Monto');
                      if (err != null) return err;
                      final n = double.tryParse(v!.trim().replaceAll(',', '.'));
                      if (n == null) return 'Ingresa un número válido';
                      if (n < 0) return 'El monto no puede ser negativo';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _obsCtrl,
                    enabled: !isSaving,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Observaciones (sobrantes/faltantes)',
                      alignLabelWithHint: true,
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSaving ? null : () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSaving ? null : _submit,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                          child: isSaving
                              ? const SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: AppColors.onAccent,
                                  ),
                                )
                              : const Text('Cerrar turno'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}