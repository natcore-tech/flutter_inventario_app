// lib/presentation/widgets/cliente_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../domain/model/cliente.dart';
import '../providers/clientes_admin_provider.dart';

Future<void> showClienteForm(
  BuildContext context,
  WidgetRef    ref, {
  Cliente?     initial,
}) {
  ref.read(clientesAdminProvider.notifier).resetFormState();
  return showModalBottomSheet(
    context:           context,
    isScrollControlled:true,
    backgroundColor:   AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child:  ClienteFormSheet(initial: initial),
    ),
  );
}

class ClienteFormSheet extends ConsumerStatefulWidget {
  final Cliente? initial;
  const ClienteFormSheet({super.key, this.initial});

  @override
  ConsumerState<ClienteFormSheet> createState() => _ClienteFormSheetState();
}

class _ClienteFormSheetState extends ConsumerState<ClienteFormSheet> {
  final _formKey    = GlobalKey<FormState>();
  final _idCtrl     = TextEditingController(); // identificacion
  final _nameCtrl   = TextEditingController(); // nombres
  final _emailCtrl  = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  final _dirCtrl    = TextEditingController(); // direccion
  bool  _isActive   = true;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      final c = widget.initial!;
      _idCtrl.text    = c.identificacion;
      _nameCtrl.text  = c.nombres;
      _emailCtrl.text = c.email ?? '';
      _phoneCtrl.text = c.telefono;
      _dirCtrl.text   = c.direccion;
      _isActive       = c.esActivo;
    }
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _dirCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final payload = {
      'identificacion': _idCtrl.text.trim(),
      'nombres':        _nameCtrl.text.trim(),
      'email':          _emailCtrl.text.trim(),
      'telefono':       _phoneCtrl.text.trim(),
      'direccion':      _dirCtrl.text.trim(),
      'es_activo':      _isActive,
    };
    if (widget.initial != null) {
      await ref.read(clientesAdminProvider.notifier)
          .updateCliente(widget.initial!.id, payload);
    } else {
      await ref.read(clientesAdminProvider.notifier).createCliente(payload);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formSt   = ref.watch(clientesAdminProvider.select((s) => s.formState));
    final isSaving = formSt is ClienteFormSaving;
    final isEdit   = widget.initial != null;

    if (formSt is ClienteFormSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            
            Text(isEdit ? 'Editar Cliente' : 'Nuevo Cliente',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _idCtrl,
                    enabled: !isSaving,
                    decoration: const InputDecoration(labelText: 'Cédula/RUC *'),
                    validator: (v) => validateRequired(v, 'Identificación'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameCtrl,
                    enabled: !isSaving,
                    decoration: const InputDecoration(labelText: 'Nombres Completos *'),
                    validator: (v) => validateRequired(v, 'Nombres'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailCtrl,
                    enabled: !isSaving,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneCtrl,
                    enabled: !isSaving,
                    decoration: const InputDecoration(labelText: 'Teléfono'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _dirCtrl,
                    enabled: !isSaving,
                    decoration: const InputDecoration(labelText: 'Dirección'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),
                  
                  // Botones de acción
                  Row(
                    children: [
                      Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar'))),
                      const SizedBox(width: 12),
                      Expanded(child: ElevatedButton(
                        onPressed: isSaving ? null : _submit,
                        child: isSaving ? const CircularProgressIndicator() : Text(isEdit ? 'Guardar' : 'Crear'),
                      )),
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