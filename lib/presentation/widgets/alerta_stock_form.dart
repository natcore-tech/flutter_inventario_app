import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../domain/model/alerta_stock_minimo.dart';
import '../providers/alertas_stock_admin_provider.dart';

Future<void> showAlertaForm(BuildContext context, WidgetRef ref, {AlertaStockMinimo? initial}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => ProviderScope(parent: ProviderScope.containerOf(context), child: AlertaFormSheet(initial: initial)),
  );
}

class AlertaFormSheet extends ConsumerStatefulWidget {
  final AlertaStockMinimo? initial;
  const AlertaFormSheet({super.key, this.initial});
  @override ConsumerState<AlertaFormSheet> createState() => _AlertaFormSheetState();
}

class _AlertaFormSheetState extends ConsumerState<AlertaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _productoIdCtrl = TextEditingController(); // Idealmente un dropdown alimentado de productos
  final _cantidadCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _activa = true;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _productoIdCtrl.text = widget.initial!.productoId;
      _cantidadCtrl.text = widget.initial!.cantidadMinima.toString();
      _emailCtrl.text = widget.initial!.emailNotificacion;
      _activa = widget.initial!.activa;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final a = AlertaStockMinimo(id: widget.initial?.id ?? '', productoId: _productoIdCtrl.text, cantidadMinima: int.parse(_cantidadCtrl.text), emailNotificacion: _emailCtrl.text, activa: _activa);
    if (widget.initial != null) await ref.read(alertasStockAdminProvider.notifier).updateAlerta(a);
    else await ref.read(alertasStockAdminProvider.notifier).addAlerta(a);
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
            TextFormField(controller: _productoIdCtrl, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'ID Producto *'), validator: (v) => validateRequired(v, 'Producto ID')),
            const SizedBox(height: 12),
            TextFormField(controller: _cantidadCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'Cantidad Mínima *'), validator: (v) => validateRequired(v, 'Cantidad')),
            const SizedBox(height: 12),
            TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'Email Notificación *'), validator: validateEmail),
            SwitchListTile(title: const Text('Activa', style: TextStyle(color: AppColors.textPrimary)), activeColor: AppColors.accent, value: _activa, onChanged: (v) => setState(() => _activa = v)),
            ElevatedButton(onPressed: _submit, child: Text(widget.initial != null ? 'Actualizar' : 'Crear')),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}