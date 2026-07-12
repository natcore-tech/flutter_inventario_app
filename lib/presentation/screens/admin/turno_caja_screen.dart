// lib/presentation/screens/admin/turno_caja_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../providers/turno_caja_provider.dart';
import '../../widgets/turno_caja_form.dart';

class TurnoCajaScreen extends ConsumerWidget {
  const TurnoCajaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(turnoCajaProvider);

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: () => ref.read(turnoCajaProvider.notifier).load(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            )
          else if (state.error != null)
            _ErrorCard(
              message: state.error!,
              onRetry: () => ref.read(turnoCajaProvider.notifier).load(),
            )
          else if (state.turnoActual == null)
            _SinTurnoCard(onAbrir: () => showAbrirTurnoForm(context, ref))
          else
            _TurnoAbiertoCard(
              turno: state.turnoActual!,
              onCerrar: () => showCerrarTurnoForm(context, ref),
            ),
        ],
      ),
    );
  }
}

class _SinTurnoCard extends StatelessWidget {
  final VoidCallback onAbrir;
  const _SinTurnoCard({required this.onAbrir});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppColors.textFaint.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.point_of_sale_rounded,
                  color: AppColors.textFaint, size: 34),
            ),
            const SizedBox(height: 16),
            const Text(
              'No tienes un turno abierto',
              style: TextStyle(
                color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Abre un turno declarando el fondo inicial para\ncomenzar a registrar ventas.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAbrir,
                icon: const Icon(Icons.lock_open_rounded, size: 18),
                label: const Text('Abrir turno de caja'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
}

class _TurnoAbiertoCard extends StatelessWidget {
  final dynamic turno; // TurnoCaja
  final VoidCallback onCerrar;
  const _TurnoAbiertoCard({required this.turno, required this.onCerrar});

  @override
  Widget build(BuildContext context) {
    final t = turno;
    final horaApertura =
        '${t.fechaApertura.hour.toString().padLeft(2, '0')}:'
        '${t.fechaApertura.minute.toString().padLeft(2, '0')}';

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10, height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.success, shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Turno abierto',
                    style: TextStyle(
                      color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  Text('#${t.id}',
                      style: const TextStyle(color: AppColors.textFaint, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 16),
              _InfoRow(label: 'Cajero', value: t.nombreCajero as String),
              _InfoRow(label: 'Abierto desde', value: horaApertura),
              _InfoRow(
                label: 'Fondo inicial',
                value: '\$${(t.montoApertura as double).toStringAsFixed(2)}',
                valueColor: AppColors.accent,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onCerrar,
            icon: const Icon(Icons.lock_outline_rounded, size: 18),
            label: const Text('Cerrar turno'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, style: const TextStyle(color: AppColors.error), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      );
}