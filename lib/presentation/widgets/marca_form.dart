// lib/presentation/widgets/marca_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../domain/model/marca.dart';
import '../providers/marca_provider.dart';

Future<void> showMarcaForm(BuildContext context, WidgetRef ref, {Marca? marcaAEditar}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: MarcaFormSheet(marcaAEditar: marcaAEditar),
      ),
    ),
  );
}

class MarcaFormSheet extends ConsumerStatefulWidget {
  final Marca? marcaAEditar;
  const MarcaFormSheet({super.key, this.marcaAEditar});

  @override
  ConsumerState<MarcaFormSheet> createState() => _MarcaFormSheetState();
}

class _MarcaFormSheetState extends ConsumerState<MarcaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  bool _isSaving = false;
  String? _localError;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.marcaAEditar?.nombre ?? '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _localError = null;
    });

    final marca = Marca(
      id: widget.marcaAEditar?.id,
      nombre: _nombreCtrl.text.trim(),
    );

    final success = await ref.read(marcasProvider.notifier).guardarMarca(marca);

    if (success && mounted) {
      Navigator.pop(context);
    } else {
      setState(() {
        _isSaving = false;
        _localError = ref.read(marcasProvider).error ?? 'Error al guardar.';
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
            Text(widget.marcaAEditar == null ? 'Nueva Marca' : 'Editar Marca', style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
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
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Nombre de la Marca'),
              style: const TextStyle(color: AppColors.textPrimary),
              validator: (v) => v == null || v.trim().isEmpty ? 'El nombre es obligatorio' : null,
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