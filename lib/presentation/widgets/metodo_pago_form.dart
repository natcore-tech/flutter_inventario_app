// lib/presentation/widgets/metodo_pago_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_inventario_app/presentation/providers/metodo_pago_admin_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../presentation/domain/model/metodo_pago.dart';

Future<void> showMetodoPagoForm(
  BuildContext context,
  WidgetRef ref, {
  MetodoPago? initial,
}) {
  ref.read(metodoPagoAdminProvider.notifier).resetFormState();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child: MetodoPagoFormSheet(initial: initial),
    ),
  );
}

class MetodoPagoFormSheet extends ConsumerStatefulWidget {
  final MetodoPago? initial;
  const MetodoPagoFormSheet({super.key, this.initial});

  @override
  ConsumerState<MetodoPagoFormSheet> createState() => _MetodoPagoFormSheetState();
}

class _MetodoPagoFormSheetState extends ConsumerState<MetodoPagoFormSheet> {
  final _formKey  = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _nombreCtrl.text = widget.initial!.nombre;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final nombre = _nombreCtrl.text.trim();
    if (widget.initial != null) {
      await ref.read(metodoPagoAdminProvider.notifier)
          .updateMetodoPago(widget.initial!.id, nombre);
    } else {
      await ref.read(metodoPagoAdminProvider.notifier).createMetodoPago(nombre);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formSt   = ref.watch(metodoPagoAdminProvider.select((s) => s.formState));
    final isSaving = formSt is MetodoPagoFormSaving;
    final isEdit   = widget.initial != null;

    if (formSt is MetodoPagoFormSuccess) {
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
            Text(
              isEdit ? 'Editar: ${widget.initial!.nombre}' : 'Nuevo método de pago',
              style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            if (formSt is MetodoPagoFormError) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(formSt.message, style: const TextStyle(color: AppColors.error, fontSize: 13)),
              ),
              const SizedBox(height: 14),
            ],

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nombreCtrl,
                    enabled: !isSaving,
                    decoration: const InputDecoration(
                      labelText: 'Nombre *',
                      hintText: 'Efectivo, Tarjeta, Transferencia...',
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                    validator: (v) => validateRequired(v, 'Nombre'),
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
                          child: isSaving
                              ? const SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.onAccent),
                                )
                              : Text(isEdit ? 'Guardar cambios' : 'Crear método'),
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