import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../domain/model/marca.dart';
import '../providers/marcas_admin_provider.dart';

// Utilizando tu estilo de BottomSheet con drag handle y redondeo
class MarcaFormSheet extends ConsumerStatefulWidget {
    final Marca? initial;
    const MarcaFormSheet({super.key, this.initial});

    @override
    ConsumerState<MarcaFormSheet> createState() => _MarcaFormSheetState();
}

class _MarcaFormSheetState extends ConsumerState<MarcaFormSheet> {
    final _formKey = GlobalKey<FormState>();
    final _nombreCtrl = TextEditingController();

    @override
    void initState() {
        super.initState();
        _nombreCtrl.text = widget.initial?.nombre ?? '';
    }

    @override
    Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Form(
            key: _formKey,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                TextFormField(
                    controller: _nombreCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre de la Marca *'),
                    style: const TextStyle(color: AppColors.textPrimary),
                    validator: (v) => validateRequired(v, 'Nombre'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                onPressed: () {
                    if(_formKey.currentState!.validate()) {
                        // Lógica de guardado...
                        Navigator.pop(context);
                    }
                },
                child: const Text('Guardar Marca'),
                ),
            ],
            ),
        ),
        ),
    );
    }
}