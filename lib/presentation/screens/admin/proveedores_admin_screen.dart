// lib/presentation/screens/admin/proveedores_admin_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../domain/model/proveedor.dart';
import '../../providers/proveedores_provider.dart';
import '../../widgets/proveedor_form.dart';

class ProveedoresAdminScreen extends ConsumerStatefulWidget {
  const ProveedoresAdminScreen({super.key});

  @override
  ConsumerState<ProveedoresAdminScreen> createState() => _ProveedoresAdminScreenState();
}

class _ProveedoresAdminScreenState extends ConsumerState<ProveedoresAdminScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(proveedoresProvider.notifier).cargarProveedores();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(proveedoresProvider);
    
    final filtered = state.proveedores.where((p) {
      final query = _searchQuery.toLowerCase();
      return p.nombre.toLowerCase().contains(query) || 
             p.ruc.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Proveedores',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22, fontWeight: FontWeight.bold,
                          )),
                      Text(
                        '${state.proveedores.length} registrados',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => showProveedorForm(context, ref),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Nuevo'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: const InputDecoration(
                  hintText: 'Buscar por nombre o RUC...',
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),

        Expanded(
          child: Builder(builder: (_) {
            if (state.isLoading && state.proveedores.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              );
            }
            if (state.error != null && state.proveedores.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.error!, style: const TextStyle(color: AppColors.error)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.read(proveedoresProvider.notifier).cargarProveedores(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            if (filtered.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🏢', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(
                      _searchQuery.isEmpty ? 'Sin proveedores' : 'Sin resultados',
                      style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _ProveedorCard(
                proveedor: filtered[i],
                onToggle: () {
                  final p = filtered[i];
                  ref.read(proveedoresProvider.notifier).actualizarProveedor(
                    Proveedor(
                      id: p.id,
                      nombre: p.nombre,
                      ruc: p.ruc,
                      telefono: p.telefono,
                      email: p.email,
                      direccion: p.direccion,
                      esActivo: !p.esActivo, // Invertimos el estado
                    )
                  );
                },
                onEdit: () => showProveedorForm(context, ref, initial: filtered[i]),
                onDelete: () => _confirmDelete(context, ref, filtered[i]),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Proveedor p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '¿Eliminar proveedor?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '"${p.nombre}" se eliminará permanentemente. Si tiene órdenes de compra asociadas, el servidor rechazará la eliminación por seguridad.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(proveedoresProvider.notifier).eliminarProveedor(p.id!);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}


class _ProveedorCard extends StatelessWidget {
  final Proveedor proveedor;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProveedorCard({
    required this.proveedor,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: proveedor.esActivo ? 1.0 : 0.55,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Switch(
            value: proveedor.esActivo,
            onChanged: (_) => onToggle(),
            activeThumbColor: AppColors.accent,
            trackColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                ? AppColors.accent.withValues(alpha: 0.4)
                : AppColors.border,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        proveedor.nombre,
                        style: const TextStyle(
                          color: AppColors.textPrimary, fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!proveedor.esActivo) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Inactivo',
                          style: TextStyle(
                            color: AppColors.error, fontSize: 10, fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  'RUC: ${proveedor.ruc}',
                  style: const TextStyle(
                    color: AppColors.textFaint, fontSize: 11, fontFamily: 'monospace',
                  ),
                ),
                if (proveedor.telefono.isNotEmpty)
                  Text(
                    '📞 ${proveedor.telefono}',
                    style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppColors.error,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}