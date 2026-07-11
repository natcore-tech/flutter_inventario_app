// lib/presentation/screens/admin/venta_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_inventario_app/domain/model/producto_lite.dart';
import 'package:flutter_inventario_app/presentation/providers/venta_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../domain/model/producto_lite.dart';

class VentaScreen extends ConsumerWidget {
  const VentaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(ventaCartProvider);

    // Mostrar resultado de la última venta confirmada (si existe)
    if (cart.ultimaVentaConfirmada != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        final v = cart.ultimaVentaConfirmada!;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('✅ Venta registrada',
                style: TextStyle(color: AppColors.success)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Venta #${v.id}', style: const TextStyle(color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Text('Subtotal: \$${v.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppColors.textSecondary)),
                Text('IVA (15%): \$${v.iva.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppColors.textSecondary)),
                Text('Total: \$${v.total.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(ventaCartProvider.notifier).reset();
                },
                child: const Text('Nueva venta'),
              ),
            ],
          ),
        );
      });
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (cart.error != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(cart.error!, style: const TextStyle(color: AppColors.error)),
          ),
          const SizedBox(height: 14),
        ],

        _ClienteSection(clienteId: cart.clienteId, nombreCliente: cart.nombreCliente),
        const SizedBox(height: 16),

        const _SectionTitle('Productos'),
        const SizedBox(height: 8),
        const _ProductoSearch(),
        const SizedBox(height: 12),
        _CarritoList(items: cart.items),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Subtotal estimado: \$${cart.subtotalEstimado.toStringAsFixed(2)}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              'El IVA, promociones y total final los calcula el servidor.',
              style: TextStyle(color: AppColors.textFaint, fontSize: 11),
            ),
          ),
        ),
        const SizedBox(height: 20),

        const _SectionTitle('Pagos'),
        const SizedBox(height: 8),
        const _PagoForm(),
        const SizedBox(height: 12),
        _PagosList(pagos: cart.pagos),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: cart.isSubmitting
                ? null
                : () => ref.read(ventaCartProvider.notifier).confirmarVenta(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: cart.isSubmitting
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.onAccent),
                  )
                : const Text('Confirmar venta'),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold,
        ),
      );
}

// ── Selección de cliente ──────────────────────────────────────

class _ClienteSection extends ConsumerWidget {
  final int?    clienteId;
  final String? nombreCliente;
  const _ClienteSection({required this.clienteId, required this.nombreCliente});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: AppColors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              nombreCliente ?? 'Selecciona un cliente',
              style: TextStyle(
                color: nombreCliente != null ? AppColors.textPrimary : AppColors.textFaint,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _pickCliente(context, ref),
            child: const Text('Elegir'),
          ),
        ],
      ),
    );
  }

  void _pickCliente(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Consumer(
        builder: (context, ref, __) {
          final clientesAsync = ref.watch(clientesListProvider);
          return SizedBox(
            height: 420,
            child: clientesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
              error: (e, __) => Center(
                child: Text('Error: $e', style: const TextStyle(color: AppColors.error)),
              ),
              data: (clientes) => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: clientes.length,
                itemBuilder: (_, i) {
                  final c = clientes[i];
                  return ListTile(
                    title: Text(c.nombres, style: const TextStyle(color: AppColors.textPrimary)),
                    subtitle: Text(c.identificacion,
                        style: const TextStyle(color: AppColors.textSecondary)),
                    onTap: () {
                      ref.read(ventaCartProvider.notifier).seleccionarCliente(c.id, c.nombres);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Búsqueda / agregar productos ──────────────────────────────

class _ProductoSearch extends ConsumerStatefulWidget {
  const _ProductoSearch();

  @override
  ConsumerState<_ProductoSearch> createState() => _ProductoSearchState();
}

class _ProductoSearchState extends ConsumerState<_ProductoSearch> {
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
            hintText: 'Buscar producto...',
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
          ),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        resultsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
          ),
          error: (e, __) => Text('Error: $e', style: const TextStyle(color: AppColors.error)),
          data: (productos) {
            if (productos.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Sin resultados', style: TextStyle(color: AppColors.textFaint)),
              );
            }
            return SizedBox(
              height: 180,
              child: ListView.separated(
                itemCount: productos.length,
                separatorBuilder: (_, __) => const Divider(color: AppColors.border, height: 1),
                itemBuilder: (_, i) => _ProductoTile(producto: productos[i]),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ProductoTile extends ConsumerWidget {
  final ProductoLite producto;
  const _ProductoTile({required this.producto});

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
        dense: true,
        title: Text(producto.nombre, style: const TextStyle(color: AppColors.textPrimary)),
        subtitle: Text(
          '\$${producto.precio.toStringAsFixed(2)} · Stock: ${producto.stock}',
          style: TextStyle(
            color: producto.enStock ? AppColors.textSecondary : AppColors.error,
            fontSize: 12,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle, color: AppColors.accent),
          onPressed: producto.enStock
              ? () => ref.read(ventaCartProvider.notifier).agregarProducto(producto)
              : null,
        ),
      );
}

// ── Carrito ───────────────────────────────────────────────────

class _CarritoList extends ConsumerWidget {
  final List<CartItem> items;
  const _CarritoList({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text('Carrito vacío', style: TextStyle(color: AppColors.textFaint)),
      );
    }
    return Column(
      children: items.map((it) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(it.producto.nombre, style: const TextStyle(color: AppColors.textPrimary)),
                  Text('\$${it.producto.precio.toStringAsFixed(2)} c/u',
                      style: const TextStyle(color: AppColors.textFaint, fontSize: 11)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, size: 20),
              color: AppColors.textSecondary,
              onPressed: () => ref.read(ventaCartProvider.notifier)
                  .cambiarCantidad(it.producto.id, it.cantidad - 1),
            ),
            Text('${it.cantidad}', style: const TextStyle(color: AppColors.textPrimary)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 20),
              color: AppColors.accent,
              onPressed: () => ref.read(ventaCartProvider.notifier)
                  .cambiarCantidad(it.producto.id, it.cantidad + 1),
            ),
            Text('\$${it.subtotalEstimado.toStringAsFixed(2)}',
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: AppColors.error,
              onPressed: () => ref.read(ventaCartProvider.notifier).quitarProducto(it.producto.id),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

// ── Pagos ─────────────────────────────────────────────────────

class _PagoForm extends ConsumerStatefulWidget {
  const _PagoForm();

  @override
  ConsumerState<_PagoForm> createState() => _PagoFormState();
}

class _PagoFormState extends ConsumerState<_PagoForm> {
  int? _metodoId;
  String _metodoNombre = '';
  final _montoCtrl = TextEditingController();

  @override
  void dispose() {
    _montoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metodosAsync = ref.watch(metodosPagoListProvider);

    return Row(
      children: [
        Expanded(
          child: metodosAsync.when(
            loading: () => const LinearProgressIndicator(color: AppColors.accent),
            error: (e, __) => Text('Error: $e', style: const TextStyle(color: AppColors.error)),
            data: (metodos) => DropdownButtonFormField<int>(
              initialValue: _metodoId,
              decoration: const InputDecoration(labelText: 'Método'),
              dropdownColor: AppColors.surface2,
              style: const TextStyle(color: AppColors.textPrimary),
              items: metodos.map((m) => DropdownMenuItem(
                value: m.id,
                child: Text(m.nombre),
              )).toList(),
              onChanged: (v) {
                final m = metodos.firstWhere((m) => m.id == v);
                setState(() { _metodoId = v; _metodoNombre = m.nombre; });
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 110,
          child: TextField(
            controller: _montoCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Monto', prefixText: r'$ '),
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle, color: AppColors.accent),
          onPressed: () {
            final monto = double.tryParse(_montoCtrl.text.trim().replaceAll(',', '.'));
            if (_metodoId == null || monto == null || monto <= 0) return;
            ref.read(ventaCartProvider.notifier).agregarPago(_metodoId!, _metodoNombre, monto);
            _montoCtrl.clear();
          },
        ),
      ],
    );
  }
}

class _PagosList extends ConsumerWidget {
  final List<PagoDraft> pagos;
  const _PagosList({required this.pagos});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (pagos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Text('Sin pagos registrados (opcional al crear)',
            style: TextStyle(color: AppColors.textFaint, fontSize: 12)),
      );
    }
    return Column(
      children: List.generate(pagos.length, (i) {
        final p = pagos[i];
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(p.nombreMetodo, style: const TextStyle(color: AppColors.textPrimary)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('\$${p.monto.toStringAsFixed(2)}',
                  style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                color: AppColors.error,
                onPressed: () => ref.read(ventaCartProvider.notifier).quitarPago(i),
              ),
            ],
          ),
        );
      }),
    );
  }
}