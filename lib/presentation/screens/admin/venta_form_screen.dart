// lib/presentation/screens/admin/venta_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_inventario_app/domain/model/producto_lite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/remote/api/venta_remote_datasource.dart';
import '../../../theme/app_colors.dart';
import '../../domain/model/cliente.dart';
import '../../domain/model/metodo_pago.dart';
import '../../domain/model/producto_lite.dart';
import '../../domain/model/venta.dart';
import '../../providers/clientes_admin_provider.dart';
import '../../providers/productos_admin_provider.dart';
import '../../providers/metodo_pago_admin_provider.dart';

class _CarritoItem {
  final ProductoLite producto;
  int cantidad;
  _CarritoItem({required this.producto, this.cantidad = 1});

  double get subtotal => producto.precio * cantidad;
}

class VentaScreen extends ConsumerStatefulWidget {
  const VentaScreen({super.key});

  @override
  ConsumerState<VentaScreen> createState() => _VentaScreenState();
}

class _VentaScreenState extends ConsumerState<VentaScreen> {
  Cliente? _clienteSeleccionado;
  MetodoPago? _metodoSeleccionado;
  final List<_CarritoItem> _carrito = [];
  bool _guardando = false;

  double get _total => _carrito.fold(0.0, (s, i) => s + i.subtotal);

  void _agregarProducto(ProductoLite p) {
    final idx = _carrito.indexWhere((i) => i.producto.id == p.id);
    setState(() {
      if (idx >= 0) {
        _carrito[idx].cantidad++;
      } else {
        _carrito.add(_CarritoItem(producto: p));
      }
    });
  }

  void _quitarProducto(int productoId) {
    setState(() => _carrito.removeWhere((i) => i.producto.id == productoId));
  }

  void _cambiarCantidad(int productoId, int delta) {
    setState(() {
      final idx = _carrito.indexWhere((i) => i.producto.id == productoId);
      if (idx < 0) return;
      final nueva = _carrito[idx].cantidad + delta;
      if (nueva <= 0) {
        _carrito.removeAt(idx);
      } else {
        _carrito[idx].cantidad = nueva;
      }
    });
  }

  Future<void> _registrarVenta() async {
    if (_clienteSeleccionado == null) {
      _mostrarError('Selecciona un cliente');
      return;
    }
    if (_carrito.isEmpty) {
      _mostrarError('Agrega al menos un producto');
      return;
    }
    if (_metodoSeleccionado == null) {
      _mostrarError('Selecciona un método de pago');
      return;
    }

    setState(() => _guardando = true);
    try {
      final detalles = _carrito
          .map((i) => VentaDetalle(
                productoId: i.producto.id,
                cantidad: i.cantidad,
              ))
          .toList();

      final pagos = [
        PagoVenta(
          metodoPagoId: _metodoSeleccionado!.id,
          monto: _total,
        ),
      ];

      await ref.read(ventaDatasourceProvider).crearVenta(
            clienteId: _clienteSeleccionado!.id,
            detalles: detalles,
            pagos: pagos,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Venta registrada correctamente')),
        );
        setState(() {
          _clienteSeleccionado = null;
          _metodoSeleccionado = null;
          _carrito.clear();
        });
        context.go('/admin/ventas');
      }
    } catch (e) {
      _mostrarError(e.toString());
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientesState = ref.watch(clientesAdminProvider);
    final productosState = ref.watch(productosAdminProvider);
    final metodoPagoState = ref.watch(metodoPagoAdminProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cliente',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<Cliente>(
              value: _clienteSeleccionado,
              items: clientesState.clientes
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.nombres)))
                  .toList(),
              onChanged: (c) => setState(() => _clienteSeleccionado = c),
              decoration: const InputDecoration(hintText: 'Selecciona un cliente'),
            ),
            const SizedBox(height: 20),

            const Text('Productos',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (productosState.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                height: 160,
                child: ListView.builder(
                  itemCount: productosState.productos.length,
                  itemBuilder: (_, i) {
                    final p = productosState.productos[i];
                    return ListTile(
                      title: Text(p.nombre),
                      subtitle: Text('\$${p.precio.toStringAsFixed(2)} · Stock: ${p.stock}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle, color: AppColors.accent),
                        onPressed: p.enStock ? () => _agregarProducto(p) : null,
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),

            const Text('Carrito',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_carrito.isEmpty)
              const Text('Sin productos agregados', style: TextStyle(color: AppColors.textFaint))
            else
              ..._carrito.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text(item.producto.nombre, style: const TextStyle(color: AppColors.textPrimary))),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 20),
                          onPressed: () => _cambiarCantidad(item.producto.id, -1),
                        ),
                        Text('${item.cantidad}', style: const TextStyle(color: AppColors.textPrimary)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          onPressed: () => _cambiarCantidad(item.producto.id, 1),
                        ),
                        SizedBox(
                          width: 70,
                          child: Text('\$${item.subtotal.toStringAsFixed(2)}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(color: AppColors.textSecondary)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                          onPressed: () => _quitarProducto(item.producto.id),
                        ),
                      ],
                    ),
                  )),
            const Divider(height: 24),

            const Text('Método de Pago',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            metodoPagoState.isLoading
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<MetodoPago>(
                    value: _metodoSeleccionado,
                    items: metodoPagoState.metodos
                        .where((m) => m.esActivo)
                        .map((m) => DropdownMenuItem(value: m, child: Text(m.nombre)))
                        .toList(),
                    onChanged: (m) => setState(() => _metodoSeleccionado = m),
                    decoration: const InputDecoration(hintText: 'Selecciona un método de pago'),
                  ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('\$${_total.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppColors.accent, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardando ? null : _registrarVenta,
                child: _guardando
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Registrar Venta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}