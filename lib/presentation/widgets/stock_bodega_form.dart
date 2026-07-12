import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../domain/model/stock_bodega.dart';
import '../../domain/model/bodega.dart';
import '../../domain/model/product.dart';
import '../providers/stock_bodegas_admin_provider.dart';

Future<void> showStockBodegaForm(
  BuildContext context,
  WidgetRef ref, {
  StockBodega? initial,
  required List<Bodega> bodegas,
  required List<Product> productos,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child: StockBodegaFormSheet(initial: initial, bodegas: bodegas, productos: productos),
    ),
  );
}

class StockBodegaFormSheet extends ConsumerStatefulWidget {
  final StockBodega? initial;
  final List<Bodega> bodegas;
  final List<Product> productos;

  const StockBodegaFormSheet({
    super.key, 
    this.initial, 
    required this.bodegas, 
    required this.productos,
  });

  @override 
  ConsumerState<StockBodegaFormSheet> createState() => _StockBodegaFormSheetState();
}

class _StockBodegaFormSheetState extends ConsumerState<StockBodegaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _cantidadCtrl = TextEditingController();
  String? _bodegaId;
  String? _productoId;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _bodegaId = widget.initial!.bodegaId.toString();
      _productoId = widget.initial!.productoId.toString();
      _cantidadCtrl.text = widget.initial!.cantidad.toString();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _bodegaId == null || _productoId == null) return;
    
    final stock = StockBodega(
      id: widget.initial?.id ?? '', 
      bodegaId: _bodegaId!, 
      productoId: _productoId!, 
      cantidad: int.parse(_cantidadCtrl.text)
    );
    
    if (widget.initial != null) {
      await ref.read(stockBodegasAdminProvider.notifier).updateStock(stock);
    } 
    
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
            
            DropdownButtonFormField<String>(
              value: _bodegaId,
              dropdownColor: AppColors.surface2,
              decoration: const InputDecoration(labelText: 'Bodega *'),
              style: const TextStyle(color: AppColors.textPrimary),
              items: widget.bodegas.map((b) => DropdownMenuItem<String>(
                value: b.id.toString(), 
                child: Text(b.nombre)
              )).toList(),
              onChanged: widget.initial == null ? (v) => setState(() => _bodegaId = v) : null,
              validator: (v) => v == null ? 'Seleccione una bodega' : null,
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _productoId,
              dropdownColor: AppColors.surface2,
              decoration: const InputDecoration(labelText: 'Producto *'),
              style: const TextStyle(color: AppColors.textPrimary),
              items: widget.productos.map((p) => DropdownMenuItem<String>(
                value: p.id.toString(), 
                child: Text(p.name)
              )).toList(),
              onChanged: widget.initial == null ? (v) => setState(() => _productoId = v) : null,
              validator: (v) => v == null ? 'Seleccione un producto' : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _cantidadCtrl, 
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary), 
              decoration: const InputDecoration(labelText: 'Cantidad *'), 
              validator: (v) => validateNonNegativeInt(v, 'Cantidad')
            ),
            const SizedBox(height: 20),
            
            ElevatedButton(onPressed: _submit, child: Text(widget.initial != null ? 'Actualizar Stock' : 'Asignar Stock')),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}