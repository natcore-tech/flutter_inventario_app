// lib/presentation/widgets/producto_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../domain/model/producto.dart';
import '../providers/producto_provider.dart';
import '../providers/categoria_provider.dart';

Future<void> showProductoForm(BuildContext context, WidgetRef ref, {Producto? productoAEditar}) {
  // Asegurarnos de que las categorías estén cargadas para el Dropdown
  ref.read(categoriasProvider.notifier).cargarCategorias();

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child: FractionallySizedBox(
        heightFactor: 0.9, // Muy alto porque tiene muchos campos
        child: ProductoFormSheet(productoAEditar: productoAEditar),
      ),
    ),
  );
}

class ProductoFormSheet extends ConsumerStatefulWidget {
  final Producto? productoAEditar;
  const ProductoFormSheet({super.key, this.productoAEditar});

  @override
  ConsumerState<ProductoFormSheet> createState() => _ProductoFormSheetState();
}

class _ProductoFormSheetState extends ConsumerState<ProductoFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _precioCtrl;
  late final TextEditingController _stockCtrl;
  
  int? _categoriaSeleccionadaId;
  bool _esActivo = true;
  bool _isSaving = false;
  String? _localError;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.productoAEditar?.nombre ?? '');
    _descCtrl = TextEditingController(text: widget.productoAEditar?.descripcion ?? '');
    _precioCtrl = TextEditingController(text: widget.productoAEditar?.precio.toString() ?? '');
    _stockCtrl = TextEditingController(text: widget.productoAEditar?.stock.toString() ?? '0');
    _esActivo = widget.productoAEditar?.esActivo ?? true;
    _categoriaSeleccionadaId = widget.productoAEditar?.categoriaId;
    
    if (_categoriaSeleccionadaId == 0) _categoriaSeleccionadaId = null;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    _precioCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoriaSeleccionadaId == null) {
      setState(() => _localError = 'Seleccione una categoría');
      return;
    }

    setState(() {
      _isSaving = true;
      _localError = null;
    });

    final producto = Producto(
      id: widget.productoAEditar?.id,
      nombre: _nombreCtrl.text.trim(),
      descripcion: _descCtrl.text.trim(),
      precio: double.tryParse(_precioCtrl.text) ?? 0.0,
      stock: int.tryParse(_stockCtrl.text) ?? 0,
      esActivo: _esActivo,
      categoriaId: _categoriaSeleccionadaId!,
    );

    final success = await ref.read(productosProvider.notifier).guardarProducto(producto);

    if (success && mounted) {
      Navigator.pop(context);
    } else {
      setState(() {
        _isSaving = false;
        _localError = ref.read(productosProvider).error ?? 'Error al guardar el producto.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriasState = ref.watch(categoriasProvider);

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
              Text(widget.productoAEditar == null ? 'Nuevo Producto' : 'Editar Producto', style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
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
                    decoration: const InputDecoration(labelText: 'Nombre del Producto'),
                    style: const TextStyle(color: AppColors.textPrimary),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  // Dropdown de Categorías
                  DropdownButtonFormField<int>(
                    value: _categoriaSeleccionadaId,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    dropdownColor: AppColors.surface,
                    style: const TextStyle(color: AppColors.textPrimary),
                    items: categoriasState.categorias.map((cat) {
                      return DropdownMenuItem<int>(
                        value: cat.id,
                        child: Text(cat.nombre, style: const TextStyle(color: AppColors.textPrimary)),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _categoriaSeleccionadaId = val),
                    validator: (v) => v == null ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _precioCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Precio de Venta', prefixText: '\$ '),
                          style: const TextStyle(color: AppColors.textPrimary),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Req.';
                            final val = double.tryParse(v);
                            if (val == null || val <= 0) return '> 0';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _stockCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Stock Inicial'),
                          style: const TextStyle(color: AppColors.textPrimary),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Req.';
                            final val = int.tryParse(v);
                            if (val == null || val < 0) return '>= 0';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Descripción (Opcional)', alignLabelWithHint: true),
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    title: const Text('Producto Activo', style: TextStyle(color: AppColors.textPrimary)),
                    value: _esActivo,
                    activeColor: AppColors.accent,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setState(() => _esActivo = val),
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