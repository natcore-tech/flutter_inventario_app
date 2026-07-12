// lib/presentation/screens/admin/clientes_admin_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../providers/clientes_admin_provider.dart';
import '../../widgets/cliente_form.dart';

class ClientesAdminScreen extends ConsumerWidget {
  const ClientesAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clientesAdminProvider);
    final filtered = state.filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Clientes'),
        actions: [
          IconButton(
            onPressed: () => ref.read(clientesAdminProvider.notifier).load(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: ref.read(clientesAdminProvider.notifier).setSearch,
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre o RUC...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          // Lista de clientes
          Expanded(
            child: state.isLoading 
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final cliente = filtered[i];
                    return ListTile(
                      tileColor: AppColors.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      title: Text(cliente.nombres),
                      subtitle: Text(cliente.identificacion),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: () => showClienteForm(context, ref, initial: cliente),
                    );
                  },
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showClienteForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}