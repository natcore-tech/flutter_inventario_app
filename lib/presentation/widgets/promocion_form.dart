import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../domain/model/promocion.dart';
import '../providers/promociones_admin_provider.dart';
import '../providers/products_admin_provider.dart'; 

Future<void> showPromocionForm(BuildContext context, WidgetRef ref, {Promocion? initial}) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: PromocionFormSheet(initial: initial),
        ),
    );
    }

    class PromocionFormSheet extends ConsumerStatefulWidget {
    final Promocion? initial;
    const PromocionFormSheet({super.key, this.initial});

    @override
    ConsumerState<PromocionFormSheet> createState() => _PromocionFormSheetState();
    }

    class _PromocionFormSheetState extends ConsumerState<PromocionFormSheet> {
    final _formKey = GlobalKey<FormState>();
    final _descCtrl = TextEditingController();
    
    String? _productoId;
    DateTime _fechaInicio = DateTime.now();
    DateTime _fechaFin = DateTime.now().add(const Duration(days: 7));
    bool _activa = true;
    bool _isSaving = false;

    @override
    void initState() {
        super.initState();
        if (widget.initial != null) {
        final p = widget.initial!;
        _productoId = p.productoId;
        _descCtrl.text = p.porcentajeDescuento.toString();
        _fechaInicio = p.fechaInicio;
        _fechaFin = p.fechaFin;
        _activa = p.activa;
        }
    }

    Future<void> _pickDate(bool isStart) async {
        final picked = await showDatePicker(
        context: context,
        initialDate: isStart ? _fechaInicio : _fechaFin,
        firstDate: DateTime(2024),
        lastDate: DateTime(2030),
        builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
                primary: AppColors.accent, onPrimary: AppColors.onAccent, surface: AppColors.surface2,
            ),
            ),
            child: child!,
        ),
        );
        if (picked != null) {
        setState(() {
            if (isStart) _fechaInicio = picked;
            else _fechaFin = picked;
        });
        }
    }

    Future<void> _submit() async {
        if (!_formKey.currentState!.validate() || _productoId == null) return;
        setState(() => _isSaving = true);
        
        final promo = Promocion(
        id: widget.initial?.id ?? '',
        productoId: _productoId!,
        porcentajeDescuento: double.parse(_descCtrl.text),
        fechaInicio: _fechaInicio,
        fechaFin: _fechaFin,
        activa: _activa,
        );

        final notifier = ref.read(promocionesAdminProvider.notifier);
        if (widget.initial != null) await notifier.updatePromocion(promo);
        else await notifier.addPromocion(promo);
        
        if (mounted) Navigator.pop(context);
    }

    @override
    Widget build(BuildContext context) {
        final productosState = ref.watch(productsAdminProvider);

        return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
                Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
                Text(widget.initial != null ? 'Editar Promoción' : 'Nueva Promoción', style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                Form(
                key: _formKey,
                child: Column(
                    children: [
                    DropdownButtonFormField<String>(
                        value: _productoId,
                        dropdownColor: AppColors.surface2,
                        decoration: const InputDecoration(labelText: 'Producto *'),
                        style: const TextStyle(color: AppColors.textPrimary),
                        items: productosState.valueOrNull?.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList() ?? [],
                        onChanged: (v) => setState(() => _productoId = v),
                        validator: (v) => v == null ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                        controller: _descCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Descuento (%) *'),
                        style: const TextStyle(color: AppColors.textPrimary),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 14),
                    Row(
                        children: [
                        Expanded(
                            child: InkWell(
                            onTap: () => _pickDate(true),
                            child: InputDecorator(
                                decoration: const InputDecoration(labelText: 'Inicio', border: OutlineInputBorder()),
                                child: Text('${_fechaInicio.day}/${_fechaInicio.month}/${_fechaInicio.year}', style: const TextStyle(color: AppColors.textPrimary)),
                            ),
                            ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: InkWell(
                            onTap: () => _pickDate(false),
                            child: InputDecorator(
                                decoration: const InputDecoration(labelText: 'Fin', border: OutlineInputBorder()),
                                child: Text('${_fechaFin.day}/${_fechaFin.month}/${_fechaFin.year}', style: const TextStyle(color: AppColors.textPrimary)),
                            ),
                            ),
                        ),
                        ],
                    ),
                    const SizedBox(height: 20),
                    
                    SwitchListTile(
                        title: const Text('Promoción Activa', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                        activeColor: AppColors.accent,
                        contentPadding: EdgeInsets.zero,
                        value: _activa,
                        onChanged: (v) => setState(() => _activa = v),
                    ),
                    const SizedBox(height: 24),
                    
                    Row(
                        children: [
                        Expanded(child: OutlinedButton(onPressed: _isSaving ? null : () => Navigator.pop(context), child: const Text('Cancelar'))),
                        const SizedBox(width: 12),
                        Expanded(child: ElevatedButton(onPressed: _isSaving ? null : _submit, child: _isSaving ? const CircularProgressIndicator(color: AppColors.onAccent) : Text(widget.initial != null ? 'Guardar' : 'Crear'))),
                        ],
                    ),
                    ],
                ),
                ),
            ],
            ),
        ),
        );
    }
    }