// lib/presentation/widgets/devolucion_cliente_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_inventario_app/presentation/domain/model/devolucion_cliente.dart';
import 'package:flutter_inventario_app/presentation/domain/model/producto_lite.dart';
import 'package:flutter_inventario_app/presentation/providers/devolucion_cliente_admin_provider.dart';
import 'package:flutter_inventario_app/presentation/providers/producto_search_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../core/utils/validators.dart';


Future<void> showDevolucionForm(BuildContext context, WidgetRef ref) {
  ref.read(devolucionAdminProvider.notifier).resetFormState();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child: const _DevolucionFormSheet(),
    ),
  );
}

class _DevolucionFormSheet extends ConsumerStatefulWidget {
  const _DevolucionFormSheet();

  @override
  ConsumerState<_DevolucionFormSheet> createState() => _DevolucionFormSheetState();
}

class _DevolucionFormSheetState extends ConsumerState<_DevolucionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _motivoCtrl = TextEditingController();
  final _cantidadCtrl = TextEditingController(text: '1');
  ProductoLite? _productoElegido;
  EstadoProductoDevuelto _estado = EstadoProductoDevuelto.bueno;

  @override
  void dispose() {
    _motivoCtrl.dispose();
    _cantidadCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_productoElegido == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un producto')));
      return;
    }
    final cantidad = int.tryParse(_cantidadCtrl.text.trim()) ?? 0;
    if (cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La cantidad debe ser mayor a 0')));
      return;
    }

    await ref.read(devolucionAdminProvider.notifier).crearDevolucion(
          productoId: _productoElegido!.id,
          motivo:     _motivoCtrl.text.trim(),
          cantidad:   cantidad,
          estadoProducto: _estado,
        );
  }

  @override
  Widget build(BuildContext context) {
    final formSt   = ref.watch(devolucionAdminProvider.select((s) => s.formState));
    final isSaving = formSt is DevolucionFormSaving;

    if (formSt is DevolucionFormSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }

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
                width: 40, height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Text('Registrar devolución',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            if (formSt is DevolucionFormError) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(formSt.message, style: const TextStyle(color: AppColors.error, fontSize: 13)),
              ),
              const SizedBox(height: 14),
            ],

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selector de producto
                  _ProductoPicker(
                    seleccionado: _productoElegido,
                    onSelect: (p) => setState(() => _productoElegido = p),
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _cantidadCtrl,
                    enabled: !isSaving,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Cantidad devuelta *'),
                    style: const TextStyle(color: AppColors.textPrimary),
                    validator: (v) => validateRequired(v, 'Cantidad'),
                  ),
                  const SizedBox(height: 14),

                  DropdownButtonFormField<EstadoProductoDevuelto>(
                    initialValue: _estado,
                    decoration: const InputDecoration(labelText: 'Estado del producto *'),
                    dropdownColor: AppColors.surface2,
                    style: const TextStyle(color: AppColors.textPrimary),
                    items: EstadoProductoDevuelto.values.map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(estadoProductoLabel(e)),
                    )).toList(),
                    onChanged: isSaving ? null : (v) => setState(() => _estado = v!),
                  ),
                  if (_estado == EstadoProductoDevuelto.bueno)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text('✅ Este producto reingresará al stock automáticamente.',
                          style: TextStyle(color: AppColors.success, fontSize: 12)),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text('⚠️ Este producto NO reingresará al stock.',
                          style: TextStyle(color: AppColors.warning, fontSize: 12)),
                    ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _motivoCtrl,
                    enabled: !isSaving,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Motivo de la devolución *',
                      alignLabelWithHint: true,
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                    validator: (v) => validateRequired(v, 'Motivo'),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSaving ? null : () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSaving ? null : _submit,
                          child: isSaving
                              ? const SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.onAccent),
                                )
                              : const Text('Registrar'),
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

class _ProductoPicker extends ConsumerStatefulWidget {
  final ProductoLite? seleccionado;
  final void Function(ProductoLite) onSelect;
  const _ProductoPicker({required this.seleccionado, required this.onSelect});

  @override
  ConsumerState<_ProductoPicker> createState() => _ProductoPickerState();
}

class _ProductoPickerState extends ConsumerState<_ProductoPicker> {
  final _ctrl = TextEditingController();
  String _query = '';
  bool _showResults = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(productosSearchProvider(_query));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.seleccionado != null && !_showResults)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Expanded(
                  child: Text(widget.seleccionado!.nombre,
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                ),
                TextButton(
                  onPressed: () => setState(() => _showResults = true),
                  child: const Text('Cambiar'),
                ),
              ],
            ),
          )
        else ...[
          TextField(
            controller: _ctrl,
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              labelText: 'Producto devuelto *',
              hintText: 'Buscar producto...',
              prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
            ),
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          resultsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
            ),
            error: (e, __) => Text('Error: $e', style: const TextStyle(color: AppColors.error)),
            data: (productos) {
              if (productos.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('Sin resultados', style: TextStyle(color: AppColors.textFaint)),
                );
              }
              return SizedBox(
                height: 140,
                child: ListView.builder(
                  itemCount: productos.length,
                  itemBuilder: (_, i) {
                    final p = productos[i];
                    return ListTile(
                      dense: true,
                      title: Text(p.nombre, style: const TextStyle(color: AppColors.textPrimary)),
                      onTap: () {
                        widget.onSelect(p);
                        setState(() => _showResults = false);
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}