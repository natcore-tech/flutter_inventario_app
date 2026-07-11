import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../providers/marcas_admin_provider.dart';
import '../../widgets/search_bar.dart'; // Tu widget de búsqueda

class MarcasAdminScreen extends ConsumerWidget {
    const MarcasAdminScreen({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
    final marcasState = ref.watch(marcasAdminProvider);

    return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
            children: [
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: SearchBar(onChanged: (val) { /* Filtro de búsqueda */ }),
            ),
            Expanded(
            child: marcasState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e')),
                data: (marcas) => ListView.builder(
                itemCount: marcas.length,
                itemBuilder: (context, i) => ListTile(
                    title: Text(marcas[i].nombre, style: const TextStyle(color: AppColors.textPrimary)),
                ),
                ),
            ),
            ),
        ],
        ),
    );
    }
}