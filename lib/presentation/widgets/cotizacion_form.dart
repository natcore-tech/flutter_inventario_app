// lib/presentation/widgets/cotizacion_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_inventario_app/presentation/domain/model/cotizacion.dart';
import 'package:flutter_inventario_app/presentation/domain/model/producto_lite.dart';
import 'package:flutter_inventario_app/presentation/providers/cotizacion_admin_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../core/utils/validators.dart';


class _DetalleDraft {
  final ProductoLite producto;
  final int cantidad;
  final double precioPropuesto;
  const _DetalleDraft({
    required this.producto,
    required this.cantidad,
    required this.precioPropuesto,
  });

  double get subtotal => cantidad * precioPropuesto;
}

Future<void> showCotizacionForm(BuildContext context, WidgetRef ref) {
  ref.read(cotizacionAdminProvider.notifier).resetFormState();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child: const _CotizacionFormSheet(),
    ),
  );
}

class _CotizacionFormSheet extends ConsumerStatefulWidget {
  const _CotizacionFormSheet();

  @override
  ConsumerState<_CotizacionFormSheet> createState() => _CotizacionFormSheetState();
}

class _CotizacionFormSheetState extends ConsumerState<_CotizacionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _codigoCtrl = TextEditingController();
  int?    _proveedorId;
  String  _proveedorNombre = '';
  DateTime? _fechaValidez;
  final List<_DetalleDraft> _detalles = [];

  @override
  void dispose() {
    _codigoCtrl.dispose();
    super.dispose();
  }

  double get _totalPropuesto => _detalles.fold(0.0, (sum, d) => sum + d.subtotal);

  Future<void> _elegirFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 15)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha != null) setState(() => _fechaValidez = fecha);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_proveedorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un proveedor')));
      return;
    }
    if (_fechaValidez == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona la fecha de validez')));
      return;
    }
    if (_detalles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos un producto')));
      return;
    }

    await ref.read(cotizacionAdminProvider.notifier).crearCotizacion(
          proveedorId:      _proveedorId!,
          codigoCotizacion: _codigoCtrl.text.trim(),
          fechaValidez:     _fechaValidez!,
          totalPropuesto:   _totalPropuesto,
          detalles: _detalles.map((d) => CotizacionDetalle(
                productoId:      d.producto.id,
                cantidad:        d.cantidad,
                precioPropuesto: d.precioPropuesto,
              )).toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final formSt   = ref.watch(cotizacionAdminProvider.select((s) => s.formState));
    final isSaving = formSt is CotizacionFormSaving;

    if (formSt is CotizacionFormSuccess) {
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
            const Text('Nueva cotización',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            if (formSt is CotizacionFormError) ...[
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
                  // Proveedor
                  Consumer(builder: (context, ref, __) {
                    final proveedoresAsync = ref.watch(proveedoresListProvider);
                    return proveedoresAsync.when(
                      loading: () => const LinearProgressIndicator(color: AppColors.accent),
                      error: (e, __) => Text('Error: $e', style: const TextStyle(color: AppColors.error)),
                      data: (proveedores) => DropdownButtonFormField<int>(
                        initialValue: _proveedorId,
                        decoration: const InputDecoration(labelText: 'Proveedor *'),
                        dropdownColor: AppColors.surface2,
                        style: const TextStyle(color: AppColors.textPrimary),
                        items: proveedores.map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text('${p.nombre} (${p.ruc})'),
                        )).toList(),
                        onChanged: isSaving ? null : (v) {
                          final p = proveedores.firstWhere((p) => p.id == v);
                          setState(() { _proveedorId = v; _proveedorNombre = p.nombre; });
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _codigoCtrl,
                    enabled: !isSaving,
                    decoration: const InputDecoration(
                      labelText: 'Código de cotización *',
                      hintText: 'COT-2026-001',
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                    validator: (v) => validateRequired(v, 'Código'),
                  ),
                  const SizedBox(height: 14),

                  InkWell(
                    onTap: isSaving ? null : _elegirFecha,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Fecha de validez *'),
                      child: Text(
                        _fechaValidez == null
                            ? 'Selecciona una fecha'
                            : '${_fechaValidez!.day.toString().padLeft(2,'0')}/${_fechaValidez!.month.toString().padLeft(2,'0')}/${_fechaValidez!.year}',
                        style: TextStyle(
                          color: _fechaValidez == null ? AppColors.textFaint : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text('Productos a cotizar', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _ProductoPrecioSearch(onAgregar: (producto, precio) {
                    setState(() {
                      final idx = _detalles.indexWhere((d) => d.producto.id == producto.id);
                      if (idx >= 0) {
                        _detalles[idx] = _DetalleDraft(
                          producto: producto,
                          cantidad: _detalles[idx].cantidad + 1,
                          precioPropuesto: precio,
                        );
                      } else {
                        _detalles.add(_DetalleDraft(producto: producto, cantidad: 1, precioPropuesto: precio));
                      }
                    });
                  }),
                  const SizedBox(height: 12),

                  if (_detalles.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Sin productos agregados', style: TextStyle(color: AppColors.textFaint)),
                    )
                  else
                    ..._detalles.asMap().entries.map((entry) {
                      final i = entry.key;
                      final d = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(d.producto.nombre, style: const TextStyle(color: AppColors.textPrimary)),
                                  Text('${d.cantidad} x \$${d.precioPropuesto.toStringAsFixed(2)}',
                                      style: const TextStyle(color: AppColors.textFaint, fontSize: 11)),
                                ],
                              ),
                            ),
                            Text('\$${d.subtotal.toStringAsFixed(2)}',
                                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              color: AppColors.error,
                              onPressed: () => setState(() => _detalles.removeAt(i)),
                            ),
                          ],
                        ),
                      );
                    }),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('Total propuesto: \$${_totalPropuesto.toStringAsFixed(2)}',
                        style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
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
                              : const Text('Crear cotización'),
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

class _ProductoPrecioSearch extends ConsumerStatefulWidget {
  final void Function(ProductoLite producto, double precio) onAgregar;
  const _ProductoPrecioSearch({required this.onAgregar});

  @override
  ConsumerState<_ProductoPrecioSearch> createState() => _ProductoPrecioSearchState();
}

class _ProductoPrecioSearchState extends ConsumerState<_ProductoPrecioSearch> {
  final _ctrl = TextEditingController();
  String _query = '';

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
        TextField(
          controller: _ctrl,
          onChanged: (v) => setState(() => _query = v),
          decoration: const InputDecoration(
            hintText: 'Buscar producto para cotizar...',
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
                    subtitle: Text('Precio actual: \$${p.precio.toStringAsFixed(2)}',
                        style: const TextStyle(color: AppColors.textFaint, fontSize: 11)),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle, color: AppColors.accent),
                      onPressed: () => _pedirPrecio(p),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  void _pedirPrecio(ProductoLite producto) {
    final ctrl = TextEditingController(text: producto.precio.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Precio propuesto: ${producto.nombre}',
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(prefixText: r'$ '),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final precio = double.tryParse(ctrl.text.trim().replaceAll(',', '.'));
              if (precio == null || precio <= 0) return;
              widget.onAgregar(producto, precio);
              Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}