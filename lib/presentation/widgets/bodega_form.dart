import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../domain/model/bodega.dart';
import '../providers/bodegas_admin_provider.dart';

Future<void> showBodegaForm(BuildContext context, WidgetRef ref, {Bodega? initial}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => ProviderScope(parent: ProviderScope.containerOf(context), child: BodegaFormSheet(initial: initial)),
  );
}

class BodegaFormSheet extends ConsumerStatefulWidget {
  final Bodega? initial;
  const BodegaFormSheet({super.key, this.initial});
  @override ConsumerState<BodegaFormSheet> createState() => _BodegaFormSheetState();
}

class _BodegaFormSheetState extends ConsumerState<BodegaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _dirCtrl = TextEditingController();
  bool _activa = true;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _nombreCtrl.text = widget.initial!.nombre;
      _dirCtrl.text = widget.initial!.direccion ?? '';
      _activa = widget.initial!.activa;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final b = Bodega(id: widget.initial?.id ?? '', nombre: _nombreCtrl.text, direccion: _dirCtrl.text, activa: _activa);
    if (widget.initial != null) await ref.read(bodegasAdminProvider.notifier).updateBodega(b);
    else await ref.read(bodegasAdminProvider.notifier).addBodega(b);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 12),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            TextFormField(controller: _nombreCtrl, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'Nombre Bodega *'), validator: (v) => validateRequired(v, 'Nombre')),
            const SizedBox(height: 12),
            TextFormField(controller: _dirCtrl, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'Dirección')),
            SwitchListTile(title: const Text('Activa', style: TextStyle(color: AppColors.textPrimary)), activeColor: AppColors.accent, value: _activa, onChanged: (v) => setState(() => _activa = v)),
            ElevatedButton(onPressed: _submit, child: Text(widget.initial != null ? 'Actualizar' : 'Crear')),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}