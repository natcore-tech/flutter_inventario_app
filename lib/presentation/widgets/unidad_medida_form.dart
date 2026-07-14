// lib/presentation/widgets/unidad_medida_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../domain/model/unidad_medida.dart';
import '../providers/unidad_medida_provider.dart';

Future<void> showUnidadMedidaForm(BuildContext context, WidgetRef ref, {UnidadMedida? unidadAEditar}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: UnidadMedidaFormSheet(unidadAEditar: unidadAEditar),
      ),
    ),
  );
}

class UnidadMedidaFormSheet extends ConsumerStatefulWidget {
  final UnidadMedida? unidadAEditar;
  const UnidadMedidaFormSheet({super.key, this.unidadAEditar});

  @override
  ConsumerState<UnidadMedidaFormSheet> createState() => _UnidadMedidaFormSheetState();
}

class _UnidadMedidaFormSheetState extends ConsumerState<UnidadMedidaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _abreviaturaCtrl;
  
  bool _isSaving = false;
  String? _localError;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.unidadAEditar?.nombre ?? '');
    _abreviaturaCtrl = TextEditingController(text: widget.unidadAEditar?.abreviatura ?? '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _abreviaturaCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _localError = null;
    });

    final unidad = UnidadMedida(
      id: widget.unidadAEditar?.id,
      nombre: _nombreCtrl.text.trim(),
      abreviatura: _abreviaturaCtrl.text.trim(),
    );

    final success = await ref.read(unidadesMedidaProvider.notifier).guardarUnidad(unidad);

    if (success && mounted) {
      Navigator.pop(context);
    } else {
      setState(() {
        _isSaving = false;
        _localError = ref.read(unidadesMedidaProvider).error ?? 'Error al guardar.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(widget.unidadAEditar == null ? 'Nueva Unidad de Medida' : 'Editar Unidad', style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            if (_localError != null) ...[
              Container(
                width: double.infinity, padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(_localError!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
              ),
              const SizedBox(height: 14),
            ],

            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre (Ej: Kilogramo)'),
              style: const TextStyle(color: AppColors.textPrimary),
              validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _abreviaturaCtrl,
              decoration: const InputDecoration(labelText: 'Abreviatura (Ej: kg)'),
              style: const TextStyle(color: AppColors.textPrimary),
              validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                child: _isSaving 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.onAccent, strokeWidth: 2.5)) 
                  : const Text('Guardar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}