// lib/presentation/screens/admin/crear_traslado_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../domain/model/traslado_bodega.dart';
import '../../providers/traslado_bodega_provider.dart';

class CrearTrasladoScreen extends ConsumerStatefulWidget {
  const CrearTrasladoScreen({super.key});

  @override
  ConsumerState<CrearTrasladoScreen> createState() => _CrearTrasladoScreenState();
}

class _CrearTrasladoScreenState extends ConsumerState<CrearTrasladoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _origenCtrl = TextEditingController();
  final _destinoCtrl = TextEditingController();
  
  // Lista dinámica de detalles en memoria
  List<TrasladoBodegaDetalle> _detalles = [];
  
  bool _isSaving = false;

  void _agregarFilaDetalle() {
    setState(() {
      _detalles.add(TrasladoBodegaDetalle(productoId: 0, cantidad: 1));
    });
  }

  void _eliminarFilaDetalle(int index) {
    setState(() {
      _detalles.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_origenCtrl.text.trim() == _destinoCtrl.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La bodega destino no puede ser igual a la de origen'), backgroundColor: AppColors.error));
      return;
    }

    if (_detalles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agrega al menos un producto al traslado'), backgroundColor: AppColors.error));
      return;
    }

    // Validar que no haya IDs en cero o cantidades nulas en los detalles visuales
    // Como los TextField actualizan el objeto directamente, ya deberíamos tener los datos.

    setState(() => _isSaving = true);

    final nuevoTraslado = TrasladoBodega(
      bodegaOrigenId: int.parse(_origenCtrl.text.trim()),
      bodegaDestinoId: int.parse(_destinoCtrl.text.trim()),
      detalles: _detalles,
    );

    final success = await ref.read(trasladosBodegaProvider.notifier).registrarTraslado(nuevoTraslado);

    if (success && mounted) {
      context.pop(); // Regresar a la lista
    } else {
      setState(() => _isSaving = false);
      if (mounted) {
        final error = ref.read(trasladosBodegaProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Error al guardar'), backgroundColor: AppColors.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nuevo Traslado', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // ── Cabecera ──
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surface,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _origenCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Bodega Origen ID', prefixIcon: Icon(Icons.storefront)),
                      style: const TextStyle(color: AppColors.textPrimary),
                      validator: (v) => v == null || v.isEmpty ? 'Req.' : null,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Icon(Icons.arrow_forward, color: AppColors.textSecondary)),
                  Expanded(
                    child: TextFormField(
                      controller: _destinoCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Bodega Destino ID', prefixIcon: Icon(Icons.store)),
                      style: const TextStyle(color: AppColors.textPrimary),
                      validator: (v) => v == null || v.isEmpty ? 'Req.' : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // ── Título Detalles ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Productos a Trasladar', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: _agregarFilaDetalle,
                    icon: const Icon(Icons.add, color: AppColors.accent),
                    label: const Text('Agregar Fila', style: TextStyle(color: AppColors.accent)),
                  )
                ],
              ),
            ),

            // ── Lista Dinámica ──
            Expanded(
              child: _detalles.isEmpty
                ? const Center(child: Text('Toca "Agregar Fila" para incluir productos.', style: TextStyle(color: AppColors.textSecondary)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _detalles.length,
                    itemBuilder: (ctx, i) {
                      return Card(
                        color: AppColors.surface2,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: _detalles[i].productoId == 0 ? '' : _detalles[i].productoId.toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'ID Prod', isDense: true),
                                  style: const TextStyle(color: AppColors.textPrimary),
                                  onChanged: (val) => _detalles[i] = TrasladoBodegaDetalle(productoId: int.tryParse(val) ?? 0, cantidad: _detalles[i].cantidad),
                                  validator: (v) => v == null || v.isEmpty || v == '0' ? 'Req.' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  initialValue: _detalles[i].cantidad.toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'Cant.', isDense: true),
                                  style: const TextStyle(color: AppColors.textPrimary),
                                  onChanged: (val) => _detalles[i] = TrasladoBodegaDetalle(productoId: _detalles[i].productoId, cantidad: int.tryParse(val) ?? 1),
                                  validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? '>0' : null,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                onPressed: () => _eliminarFilaDetalle(i),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            ),

            // ── Botón Guardar ──
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surface,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: AppColors.onAccent) 
                    : const Text('Guardar Traslado', style: TextStyle(color: AppColors.onAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}