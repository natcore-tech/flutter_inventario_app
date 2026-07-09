// lib/presentation/providers/send_notification_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/remote/api/user_remote_datasource.dart';

sealed class SendNotificationState {
  const SendNotificationState();
}

class SendNotificationIdle    extends SendNotificationState { const SendNotificationIdle(); }
class SendNotificationLoading extends SendNotificationState { const SendNotificationLoading(); }

class SendNotificationSuccess extends SendNotificationState {
  final String detail;
  final int    sent;
  final int    failed;
  const SendNotificationSuccess({
    required this.detail,
    required this.sent,
    required this.failed,
  });
}

class SendNotificationError extends SendNotificationState {
  final String message;
  const SendNotificationError(this.message);
}

class SendNotificationNotifier extends StateNotifier<SendNotificationState> {
  final UserRemoteDatasource _datasource;

  SendNotificationNotifier(this._datasource) : super(const SendNotificationIdle());

  Future<void> send({
    required String subject,
    required String message,
    int? userId,
  }) async {
    if (state is SendNotificationLoading) return;
    state = const SendNotificationLoading();
    try {
      final res = await _datasource.sendNotification(
        subject: subject,
        message: message,
        userId:  userId,
      );
      state = SendNotificationSuccess(
        detail: res['detail'] as String? ?? '',
        sent:   res['sent']   as int?    ?? 0,
        failed: res['failed'] as int?    ?? 0,
      );
    } catch (e) {
      state = SendNotificationError(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void reset() => state = const SendNotificationIdle();
}

final sendNotificationProvider = StateNotifierProvider.autoDispose<
    SendNotificationNotifier, SendNotificationState>((ref) {
  return SendNotificationNotifier(ref.watch(userDatasourceProvider));
});