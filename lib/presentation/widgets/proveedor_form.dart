// lib/presentation/widgets/proveedor_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../domain/model/proveedor.dart';
import '../providers/proveedores_provider.dart';

Future<void> showProveedorForm(
  BuildContext context,
  WidgetRef ref, {
  Proveedor? initial,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child: ProveedorFormSheet(initial: initial),
    ),
  );
}

class ProveedorFormSheet extends ConsumerStatefulWidget {
  final Proveedor? initial;
  const ProveedorFormSheet({super.key, this.initial});

  @override
  ConsumerState<ProveedorFormSheet> createState() => _ProveedorFormSheetState();
}

class _ProveedorFormSheetState extends ConsumerState<ProveedorFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _rucCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  bool _esActivo = true;
  bool _isSaving = false;
  String? _localError;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      final p = widget.initial!;
      _nombreCtrl.text = p.nombre;
      _rucCtrl.text = p.ruc;
      _telefonoCtrl.text = p.telefono;
      _emailCtrl.text = p.email;
      _direccionCtrl.text = p.direccion;
      _esActivo = p.esActivo;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _rucCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSaving = true;
      _localError = null;
    });

    final proveedor = Proveedor(
      id: widget.initial?.id,
      nombre: _nombreCtrl.text.trim(),
      ruc: _rucCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      direccion: _direccionCtrl.text.trim(),
      esActivo: _esActivo,
    );

    final notifier = ref.read(proveedoresProvider.notifier);
    bool success;

    if (widget.initial != null) {
      success = await notifier.actualizarProveedor(proveedor);
    } else {
      success = await notifier.agregarProveedor(proveedor);
    }

    if (success) {
      if (mounted) Navigator.pop(context);
    } else {
      setState(() {
        _isSaving = false;
        _localError = ref.read(proveedoresProvider).error ?? 'Error al guardar';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
              isEdit ? 'Editar Proveedor' : 'Nuevo Proveedor',
              style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            if (_localError != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _localError!,
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
                    controller: _nombreCtrl,
                    enabled: !_isSaving,
                    decoration: const InputDecoration(labelText: 'Nombre o Razón Social *'),
                    style: const TextStyle(color: AppColors.textPrimary),
                    validator: (v) => v == null || v.isEmpty ? 'El nombre es obligatorio' : null,
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _rucCtrl,
                    enabled: !_isSaving,
                    decoration: const InputDecoration(labelText: 'RUC *'),
                    style: const TextStyle(color: AppColors.textPrimary),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'El RUC es obligatorio';
                      if (v.trim().length != 13) return 'El RUC debe tener 13 dígitos';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _telefonoCtrl,
                          enabled: !_isSaving,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(labelText: 'Teléfono'),
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextFormField(
                          controller: _emailCtrl,
                          enabled: !_isSaving,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'Email'),
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _direccionCtrl,
                    enabled: !_isSaving,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Dirección',
                      alignLabelWithHint: true,
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Proveedor Activo',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                )),
                            Text('Puede recibir órdenes de compra',
                                style: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 12,
                                )),
                          ],
                        ),
                        Switch(
                          value: _esActivo,
                          onChanged: _isSaving ? null : (v) => setState(() => _esActivo = v),
                          activeThumbColor: AppColors.accent,
                          trackColor: WidgetStateProperty.resolveWith((s) =>
                            s.contains(WidgetState.selected)
                              ? AppColors.accent.withValues(alpha: 0.4)
                              : AppColors.border,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSaving ? null : () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _submit,
                          child: _isSaving
                              ? const SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: AppColors.onAccent,
                                  ),
                                )
                              : Text(isEdit ? 'Guardar cambios' : 'Crear proveedor'),
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