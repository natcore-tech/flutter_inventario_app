// lib/presentation/widgets/movimiento_inventario_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../domain/model/movimiento_inventario.dart';
import '../providers/movimiento_inventario_provider.dart';

Future<void> showMovimientoInventarioForm(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child: FractionallySizedBox(
        heightFactor: 0.85,
        child: const MovimientoInventarioFormSheet(),
      ),
    ),
  );
}

class MovimientoInventarioFormSheet extends ConsumerStatefulWidget {
  const MovimientoInventarioFormSheet({super.key});

  @override
  ConsumerState<MovimientoInventarioFormSheet> createState() => _MovimientoInventarioFormSheetState();
}

class _MovimientoInventarioFormSheetState extends ConsumerState<MovimientoInventarioFormSheet> {
  final _formKey = GlobalKey<FormState>();
  
  String _tipoSeleccionado = 'ENTRADA';
  final _productoIdCtrl = TextEditingController();
  final _proveedorIdCtrl = TextEditingController();
  final _cantidadCtrl = TextEditingController(text: '1');
  final _motivoCtrl = TextEditingController();
  
  bool _isSaving = false;
  String? _localError;

  final List<Map<String, String>> _tipos = [
    {'value': 'ENTRADA', 'label': 'Entrada (Compra/Ingreso)'},
    {'value': 'SALIDA', 'label': 'Salida (Venta/Egreso)'},
    {'value': 'AJUSTE_POS', 'label': 'Ajuste Positivo'},
    {'value': 'AJUSTE_NEG', 'label': 'Ajuste Negativo'},
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _localError = null;
    });

    final int? proveedorId = _tipoSeleccionado == 'ENTRADA' ? int.tryParse(_proveedorIdCtrl.text.trim()) : null;

    final nuevoMovimiento = MovimientoInventario(
      productoId: int.parse(_productoIdCtrl.text.trim()),
      tipo: _tipoSeleccionado,
      cantidad: int.parse(_cantidadCtrl.text.trim()),
      proveedorId: proveedorId,
      motivo: _motivoCtrl.text.trim(),
    );

    final success = await ref.read(movimientosInventarioProvider.notifier).registrarMovimiento(nuevoMovimiento);

    if (success) {
      if (mounted) Navigator.pop(context);
    } else {
      setState(() {
        _isSaving = false;
        _localError = ref.read(movimientosInventarioProvider).error ?? 'Error al guardar.';
      });
    }
  }

  @override
  void dispose() {
    _productoIdCtrl.dispose();
    _proveedorIdCtrl.dispose();
    _cantidadCtrl.dispose();
    _motivoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool requiereProveedor = _tipoSeleccionado == 'ENTRADA';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const Text('Registrar Movimiento', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(left: 24, right: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_localError != null) ...[
                    Container(
                      width: double.infinity, padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text(_localError!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                    ),
                    const SizedBox(height: 14),
                  ],

                  DropdownButtonFormField<String>(
                    value: _tipoSeleccionado,
                    decoration: const InputDecoration(labelText: 'Tipo de Movimiento'),
                    dropdownColor: AppColors.surface2,
                    style: const TextStyle(color: AppColors.textPrimary),
                    items: _tipos.map((t) => DropdownMenuItem(value: t['value'], child: Text(t['label']!))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _tipoSeleccionado = val;
                          if (val != 'ENTRADA') _proveedorIdCtrl.clear();
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _productoIdCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'ID Producto'),
                          style: const TextStyle(color: AppColors.textPrimary),
                          validator: (v) => v == null || v.isEmpty ? 'Req.' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _cantidadCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Cantidad'),
                          style: const TextStyle(color: AppColors.textPrimary),
                          validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? '>0' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (requiereProveedor) ...[
                    TextFormField(
                      controller: _proveedorIdCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'ID Proveedor (Requerido para Entrada)'),
                      style: const TextStyle(color: AppColors.textPrimary),
                      validator: (v) => requiereProveedor && (v == null || v.trim().isEmpty) ? 'Requerido para entradas' : null,
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextFormField(
                    controller: _motivoCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Motivo / Detalle (Opcional)'),
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border))),
          child: Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: _isSaving ? null : () => Navigator.pop(context), child: const Text('Cancelar'))),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  child: _isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.onAccent)) : const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}