import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../domain/model/unidad_medida.dart';
import '../providers/unidades_medida_admin_provider.dart';

Future<void> showUnidadMedidaForm(
  BuildContext context,
  WidgetRef    ref, {
  UnidadMedida? initial,
}) {
  return showModalBottomSheet(
    context:           context,
    isScrollControlled:true,
    backgroundColor:   AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => ProviderScope(
      parent:       ProviderScope.containerOf(context),
      child:        UnidadMedidaFormSheet(initial: initial),
    ),
  );
}

class UnidadMedidaFormSheet extends ConsumerStatefulWidget {
  final UnidadMedida? initial;
  const UnidadMedidaFormSheet({super.key, this.initial});

  @override
  ConsumerState<UnidadMedidaFormSheet> createState() => _UnidadMedidaFormSheetState();
}

class _UnidadMedidaFormSheetState extends ConsumerState<UnidadMedidaFormSheet> {
  final _formKey    = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _abrevCtrl  = TextEditingController();
  bool _isSaving    = false;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _nombreCtrl.text = widget.initial!.nombre;
      _abrevCtrl.text  = widget.initial!.abreviatura;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _abrevCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    
    final nuevaUnidad = UnidadMedida(
      id: widget.initial?.id ?? '',
      nombre: _nombreCtrl.text.trim(),
      abreviatura: _abrevCtrl.text.trim(),
    );

    final notifier = ref.read(unidadesMedidaAdminProvider.notifier);
    if (widget.initial != null) {
      await notifier.updateUnidadMedida(nuevaUnidad);
    } else {
      await notifier.addUnidadMedida(nuevaUnidad);
    }
    
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

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
                width:  40, height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(
              isEdit ? 'Editar Unidad' : 'Nueva Unidad de Medida',
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nombreCtrl,
                    enabled: !_isSaving,
                    decoration: const InputDecoration(labelText: 'Nombre (Ej: Kilogramo) *'),
                    style: const TextStyle(color: AppColors.textPrimary),
                    validator: (v) => validateRequired(v, 'Nombre'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _abrevCtrl,
                    enabled: !_isSaving,
                    decoration: const InputDecoration(labelText: 'Abreviatura (Ej: kg) *'),
                    style: const TextStyle(color: AppColors.textPrimary),
                    validator: (v) => validateRequired(v, 'Abreviatura'),
                  ),
                  const SizedBox(height: 24),
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
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.onAccent))
                            : Text(isEdit ? 'Guardar' : 'Crear unidad'),
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