import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../domain/model/ubicacion_fisica.dart';
import '../providers/ubicaciones_admin_provider.dart';

Future<void> showUbicacionForm(BuildContext context, WidgetRef ref, {UbicacionFisica? initial}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => ProviderScope(parent: ProviderScope.containerOf(context), child: UbicacionFormSheet(initial: initial)),
  );
}

class UbicacionFormSheet extends ConsumerStatefulWidget {
  final UbicacionFisica? initial;
  const UbicacionFormSheet({super.key, this.initial});
  @override ConsumerState<UbicacionFormSheet> createState() => _UbicacionFormSheetState();
}

class _UbicacionFormSheetState extends ConsumerState<UbicacionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _pasilloCtrl = TextEditingController();
  final _estanteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _pasilloCtrl.text = widget.initial!.pasillo;
      _estanteCtrl.text = widget.initial!.estante;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final u = UbicacionFisica(id: widget.initial?.id ?? '', pasillo: _pasilloCtrl.text, estante: _estanteCtrl.text);
    if (widget.initial != null) await ref.read(ubicacionesAdminProvider.notifier).updateUbicacion(u);
    else await ref.read(ubicacionesAdminProvider.notifier).addUbicacion(u);
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
            TextFormField(controller: _pasilloCtrl, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'Pasillo *'), validator: (v) => validateRequired(v, 'Pasillo')),
            const SizedBox(height: 12),
            TextFormField(controller: _estanteCtrl, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'Estante *'), validator: (v) => validateRequired(v, 'Estante')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _submit, child: Text(widget.initial != null ? 'Actualizar' : 'Crear')),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}