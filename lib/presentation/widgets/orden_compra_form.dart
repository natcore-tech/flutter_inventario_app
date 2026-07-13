// lib/presentation/widgets/orden_compra_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../domain/model/orden_compra.dart';
import '../../domain/model/orden_compra_detalle.dart';
import '../providers/proveedores_provider.dart';
import '../providers/ordenes_compra_provider.dart';

class _DetalleTemporal {
  int? productoId;
  int cantidad;
  double precioUnitario;

  _DetalleTemporal({
    this.productoId,
    this.cantidad = 1,
    this.precioUnitario = 0.0,
  });
}

Future<void> showOrdenCompraForm(BuildContext context, WidgetRef ref) {
  ref.read(proveedoresProvider.notifier).cargarProveedores();

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: const OrdenCompraFormSheet(),
      ),
    ),
  );
}

class OrdenCompraFormSheet extends ConsumerStatefulWidget {
  const OrdenCompraFormSheet({super.key});

  @override
  ConsumerState<OrdenCompraFormSheet> createState() => _OrdenCompraFormSheetState();
}

class _OrdenCompraFormSheetState extends ConsumerState<OrdenCompraFormSheet> {
  final _formKey = GlobalKey<FormState>();
  
  int? _proveedorIdSeleccionado;
  final List<_DetalleTemporal> _detalles = [];
  bool _isSaving = false;
  String? _localError;

  @override
  void initState() {
    super.initState();
    _detalles.add(_DetalleTemporal());
  }

  double get _totalCalculado {
    return _detalles.fold(0.0, (sum, item) => sum + (item.cantidad * item.precioUnitario));
  }

  void _agregarFilaProducto() {
    setState(() => _detalles.add(_DetalleTemporal()));
  }

  void _eliminarFilaProducto(int index) {
    setState(() => _detalles.removeAt(index));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_detalles.isEmpty) {
      setState(() => _localError = 'Debes agregar al menos un producto a la orden.');
      return;
    }

    if (_detalles.any((d) => d.productoId == null)) {
      setState(() => _localError = 'Todos los productos deben tener un ID válido.');
      return;
    }

    setState(() {
      _isSaving = true;
      _localError = null;
    });

    final detallesOficiales = _detalles.map((d) => OrdenCompraDetalle(
      productoId: d.productoId!,
      productoNombre: 'ID: ${d.productoId}',
      cantidad: d.cantidad,
      precioUnitarioCompra: d.precioUnitario,
    )).toList();

    final nuevaOrden = OrdenCompra(
      proveedorId: _proveedorIdSeleccionado!,
      totalEstimado: _totalCalculado,
      estado: 'PENDIENTE',
      detalles: detallesOficiales,
    );

    final success = await ref.read(ordenesCompraProvider.notifier).crearOrden(nuevaOrden);

    if (success) {
      if (mounted) Navigator.pop(context);
    } else {
      setState(() {
        _isSaving = false;
        _localError = ref.read(ordenesCompraProvider).error ?? 'Error al guardar la orden';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final proveedoresState = ref.watch(proveedoresProvider);
    final proveedoresActivos = proveedoresState.proveedores.where((p) => p.esActivo).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text('Emitir Orden de Compra',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 24, right: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_localError != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(_localError!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                    ),
                    const SizedBox(height: 14),
                  ],

                  DropdownButtonFormField<int>(
                    value: _proveedorIdSeleccionado,
                    decoration: const InputDecoration(labelText: 'Proveedor *'),
                    dropdownColor: AppColors.surface2,
                    style: const TextStyle(color: AppColors.textPrimary),
                    items: proveedoresActivos.map((p) {
                      return DropdownMenuItem(value: p.id, child: Text(p.nombre));
                    }).toList(),
                    onChanged: _isSaving ? null : (val) => setState(() => _proveedorIdSeleccionado = val),
                    validator: (v) => v == null ? 'Selecciona un proveedor' : null,
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Productos a Solicitar',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: _isSaving ? null : _agregarFilaProducto,
                        icon: const Icon(Icons.add, size: 16, color: AppColors.accent),
                        label: const Text('Añadir fila', style: TextStyle(color: AppColors.accent)),
                      )
                    ],
                  ),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 8),

                  ...List.generate(_detalles.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              initialValue: _detalles[index].productoId?.toString(),
                              keyboardType: TextInputType.number,
                              enabled: !_isSaving,
                              decoration: const InputDecoration(labelText: 'ID Prod', contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                              onChanged: (val) => _detalles[index].productoId = int.tryParse(val),
                              validator: (v) => v == null || v.isEmpty ? 'Req.' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              initialValue: _detalles[index].cantidad.toString(),
                              keyboardType: TextInputType.number,
                              enabled: !_isSaving,
                              decoration: const InputDecoration(labelText: 'Cant.', contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                              onChanged: (val) => _detalles[index].cantidad = int.tryParse(val) ?? 1,
                              validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? '>0' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              initialValue: _detalles[index].precioUnitario.toString(),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              enabled: !_isSaving,
                              decoration: const InputDecoration(labelText: 'Precio \$', contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                              onChanged: (val) => _detalles[index].precioUnitario = double.tryParse(val) ?? 0.0,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                            onPressed: _isSaving || _detalles.length == 1 ? null : () => _eliminarFilaProducto(index),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Estimado:', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                  Text('\$${_totalCalculado.toStringAsFixed(2)}', 
                    style: const TextStyle(color: AppColors.accent, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : () {
                        setState(() {}); // Actualiza UI antes de validar
                        _submit();
                      },
                      child: _isSaving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.onAccent))
                          : const Text('Emitir Orden'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}