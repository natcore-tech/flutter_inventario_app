// lib/presentation/widgets/categoria_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../domain/model/categoria.dart';
import '../providers/categoria_provider.dart';

Future<void> showCategoriaForm(BuildContext context, WidgetRef ref, {Categoria? categoriaAEditar}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child: FractionallySizedBox(
        heightFactor: 0.85,
        child: CategoriaFormSheet(categoriaAEditar: categoriaAEditar),
      ),
    ),
  );
}

class CategoriaFormSheet extends ConsumerStatefulWidget {
  final Categoria? categoriaAEditar;
  const CategoriaFormSheet({super.key, this.categoriaAEditar});

  @override
  ConsumerState<CategoriaFormSheet> createState() => _CategoriaFormSheetState();
}

class _CategoriaFormSheetState extends ConsumerState<CategoriaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _slugCtrl;
  late final TextEditingController _descripcionCtrl;
  bool _activa = true;
  
  bool _isSaving = false;
  String? _localError;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.categoriaAEditar?.nombre ?? '');
    _slugCtrl = TextEditingController(text: widget.categoriaAEditar?.slug ?? '');
    _descripcionCtrl = TextEditingController(text: widget.categoriaAEditar?.descripcion ?? '');
    _activa = widget.categoriaAEditar?.activa ?? true;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _slugCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  void _onNombreChanged(String value) {
    if (widget.categoriaAEditar == null) {
      // Auto-generar slug simple si es creación nueva
      final generatedSlug = value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
      _slugCtrl.text = generatedSlug;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _localError = null;
    });

    final categoria = Categoria(
      id: widget.categoriaAEditar?.id,
      nombre: _nombreCtrl.text.trim(),
      slug: _slugCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      activa: _activa,
    );

    final success = await ref.read(categoriasProvider.notifier).guardarCategoria(categoria);

    if (success && mounted) {
      Navigator.pop(context);
    } else {
      setState(() {
        _isSaving = false;
        _localError = ref.read(categoriasProvider).error ?? 'Error al guardar la categoría.';
      });
    }
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
              Text(widget.categoriaAEditar == null ? 'Nueva Categoría' : 'Editar Categoría', style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
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

                  TextFormField(
                    controller: _nombreCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre de la Categoría'),
                    style: const TextStyle(color: AppColors.textPrimary),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                    onChanged: _onNombreChanged,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _slugCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Slug (URL Amigable)',
                      helperText: 'Identificador único, sin espacios.',
                      helperStyle: TextStyle(color: AppColors.textSecondary)
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descripcionCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Descripción (Opcional)', alignLabelWithHint: true),
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    title: const Text('Categoría Activa', style: TextStyle(color: AppColors.textPrimary)),
                    subtitle: const Text('Si se inactiva, no aparecerá en ventas', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    value: _activa,
                    activeColor: AppColors.accent,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setState(() => _activa = val),
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