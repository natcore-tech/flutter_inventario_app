// lib/presentation/widgets/numero_serie_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../domain/model/orden_compra.dart';
import '../../domain/model/numero_serie.dart';
import '../providers/numero_serie_provider.dart';
import '../providers/ordenes_compra_provider.dart';

class _SerialRequerido {
  final int productoId;
  final String productoNombre;
  final TextEditingController controller;

  _SerialRequerido({
    required this.productoId,
    required this.productoNombre,
  }) : controller = TextEditingController();
}

Future<void> showNumeroSerieRegistroForm(BuildContext context, WidgetRef ref, OrdenCompra orden) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: NumeroSerieRegistroSheet(orden: orden),
      ),
    ),
  );
}

class NumeroSerieRegistroSheet extends ConsumerStatefulWidget {
  final OrdenCompra orden;
  const NumeroSerieRegistroSheet({super.key, required this.orden});

  @override
  ConsumerState<NumeroSerieRegistroSheet> createState() => _NumeroSerieRegistroSheetState();
}

class _NumeroSerieRegistroSheetState extends ConsumerState<NumeroSerieRegistroSheet> {
  final _formKey = GlobalKey<FormState>();
  final List<_SerialRequerido> _serialesRequeridos = [];
  bool _isSaving = false;
  String? _localError;

  @override
  void initState() {
    super.initState();
    _generarCamposRequeridos();
  }

  void _generarCamposRequeridos() {
    for (var detalle in widget.orden.detalles) {
      for (int i = 0; i < detalle.cantidad; i++) {
        _serialesRequeridos.add(
          _SerialRequerido(
            productoId: detalle.productoId,
            productoNombre: detalle.productoNombre ?? 'Producto ID: ${detalle.productoId}',
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    for (var req in _serialesRequeridos) {
      req.controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _localError = null;
    });

    try {
      for (var req in _serialesRequeridos) {
        final nuevoSerie = NumeroSerie(
          productoId: req.productoId,
          codigoSerial: req.controller.text.trim(),
        );

        final success = await ref.read(numerosSerieProvider.notifier).agregarNumeroSerie(nuevoSerie);
        if (!success) {
          throw Exception('Error al registrar el serial: ${req.controller.text}');
        }
      }

      final ordenActualizada = OrdenCompra(
        id: widget.orden.id,
        codigoOrden: widget.orden.codigoOrden,
        proveedorId: widget.orden.proveedorId,
        totalEstimado: widget.orden.totalEstimado,
        detalles: widget.orden.detalles,
        estado: 'RECIBIDA',
      );

      final ordenSuccess = await ref.read(ordenesCompraProvider.notifier).actualizarEstadoOrden(ordenActualizada);

      if (ordenSuccess) {
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        throw Exception('Los seriales se registraron, pero falló la actualización de la orden.');
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
        _localError = e.toString().replaceAll('Exception: ', '');
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
                  width: 40, height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const Text('Registrar Seriales',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text('Orden #${widget.orden.codigoOrden ?? widget.orden.id}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
                      decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text(_localError!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                    ),
                    const SizedBox(height: 14),
                  ],

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.accent, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text('Ingresa o escanea el número de serie físico de cada artículo recibido.',
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  ...List.generate(_serialesRequeridos.length, (index) {
                    final req = _serialesRequeridos[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextFormField(
                        controller: req.controller,
                        enabled: !_isSaving,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Serial ${index + 1} - ${req.productoNombre}',
                          prefixIcon: const Icon(Icons.qr_code_scanner, color: AppColors.textSecondary, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'El serial es obligatorio' : null,
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
          child: Row(
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
                  onPressed: _isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                  child: _isSaving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.onAccent))
                      : const Text('Finalizar Recepción'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}