// lib/presentation/widgets/ajuste_inventario_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../domain/model/ajuste_inventario.dart';
import '../providers/ajuste_inventario_provider.dart';

Future<void> showAjusteInventarioForm(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child: FractionallySizedBox(
        heightFactor: 0.85,
        child: const AjusteInventarioFormSheet(),
      ),
    ),
  );
}

class AjusteInventarioFormSheet extends ConsumerStatefulWidget {
  const AjusteInventarioFormSheet({super.key});

  @override
  ConsumerState<AjusteInventarioFormSheet> createState() => _AjusteInventarioFormSheetState();
}

class _AjusteInventarioFormSheetState extends ConsumerState<AjusteInventarioFormSheet> {
  final _formKey = GlobalKey<FormState>();
  
  String _tipoSeleccionado = 'ERROR';
  final _productoIdCtrl = TextEditingController();
  final _cantidadCtrl = TextEditingController(text: '-1');
  final _justificativoCtrl = TextEditingController();
  
  bool _isSaving = false;
  String? _localError;

  final List<Map<String, String>> _tipos = [
    {'value': 'ROBO', 'label': 'Robo o Hurto'},
    {'value': 'DANO', 'label': 'Mercadería Dañada/Rota'},
    {'value': 'CADUCIDAD', 'label': 'Caducidad/Vencimiento'},
    {'value': 'ERROR', 'label': 'Error de Conteo'},
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _localError = null;
    });

    final nuevoAjuste = AjusteInventario(
      productoId: int.parse(_productoIdCtrl.text.trim()),
      tipoAjuste: _tipoSeleccionado,
      cantidad: int.parse(_cantidadCtrl.text.trim()),
      justificativo: _justificativoCtrl.text.trim(),
    );

    final success = await ref.read(ajustesInventarioProvider.notifier).registrarAjuste(nuevoAjuste);

    if (success) {
      if (mounted) Navigator.pop(context);
    } else {
      setState(() {
        _isSaving = false;
        _localError = ref.read(ajustesInventarioProvider).error ?? 'Error al guardar el ajuste.';
      });
    }
  }

  @override
  void dispose() {
    _productoIdCtrl.dispose();
    _cantidadCtrl.dispose();
    _justificativoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              const Text('Registrar Ajuste', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
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
                    decoration: const InputDecoration(labelText: 'Motivo del Ajuste'),
                    dropdownColor: AppColors.surface2,
                    style: const TextStyle(color: AppColors.textPrimary),
                    items: _tipos.map((t) => DropdownMenuItem(value: t['value'], child: Text(t['label']!))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _tipoSeleccionado = val);
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
                          validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _cantidadCtrl,
                          keyboardType: const TextInputType.numberWithOptions(signed: true),
                          decoration: const InputDecoration(
                            labelText: 'Cantidad',
                            helperText: 'Ej: -1 o 2',
                            helperStyle: TextStyle(color: AppColors.textSecondary)
                          ),
                          style: const TextStyle(color: AppColors.textPrimary),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Req.';
                            if (int.tryParse(v) == null) return 'No válido';
                            if (int.tryParse(v) == 0) return 'Distinto de 0';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _justificativoCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Justificativo Legal / Detalle',
                      alignLabelWithHint: true,
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                    validator: (v) => v == null || v.trim().isEmpty ? 'El justificativo es obligatorio' : null,
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