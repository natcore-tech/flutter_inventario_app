// TODO Implement this library.// lib/presentation/screens/admin/send_notification_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../providers/send_notification_provider.dart';

class SendNotificationScreen extends ConsumerStatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  ConsumerState<SendNotificationScreen> createState() =>
      _SendNotificationScreenState();
}

class _SendNotificationScreenState
    extends ConsumerState<SendNotificationScreen> {
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _userIdCtrl  = TextEditingController();

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    _userIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state     = ref.watch(sendNotificationProvider);
    final isLoading = state is SendNotificationLoading;

    ref.listen<SendNotificationState>(sendNotificationProvider, (_, next) {
      if (next is SendNotificationSuccess) {
        final msg = '✅ Enviado a ${next.sent} usuario(s)'
            '${next.failed > 0 ? ' — ${next.failed} fallido(s)' : ''}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.success),
        );
        ref.read(sendNotificationProvider.notifier).reset();
        _subjectCtrl.clear();
        _messageCtrl.clear();
        _userIdCtrl.clear();
      } else if (next is SendNotificationError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:         Text(next.message),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(sendNotificationProvider.notifier).reset();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:           const Text('Enviar notificación'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation:       0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ListenableBuilder(
            listenable:
                Listenable.merge([_subjectCtrl, _messageCtrl, _userIdCtrl]),
            builder: (_, __) {
              final userId      = int.tryParse(_userIdCtrl.text);
              final isFormValid =
                  _subjectCtrl.text.isNotEmpty && _messageCtrl.text.isNotEmpty;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _subjectCtrl,
                    enabled:    !isLoading,
                    style:      const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText:  'Asunto',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _messageCtrl,
                    enabled:    !isLoading,
                    maxLines:   6,
                    style:      const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText:          'Mensaje',
                      labelStyle:         TextStyle(color: AppColors.textSecondary),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller:   _userIdCtrl,
                    enabled:      !isLoading,
                    keyboardType: TextInputType.number,
                    style:        const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText:  'ID de usuario (opcional)',
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      hintText:   'Dejar vacío para envío masivo',
                      hintStyle:  const TextStyle(color: AppColors.textFaint),
                      helperText: _userIdCtrl.text.isEmpty
                          ? 'Sin ID → se envía a todos los usuarios activos no-staff'
                          : 'Con ID → se envía solo al usuario #${_userIdCtrl.text}',
                      helperStyle: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width:  double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: isFormValid && !isLoading
                          ? () => ref
                              .read(sendNotificationProvider.notifier)
                              .send(
                                subject: _subjectCtrl.text.trim(),
                                message: _messageCtrl.text.trim(),
                                userId:  userId,
                              )
                          : null,
                      icon: isLoading
                          ? const SizedBox(
                              width:  18,
                              height: 18,
                              child:  CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color:       AppColors.onAccent,
                              ),
                            )
                          : const Icon(Icons.send_outlined),
                      label: Text(
                        isLoading
                            ? 'Enviando...'
                            : userId != null
                                ? 'Enviar al usuario #$userId'
                                : 'Enviar a todos',
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}