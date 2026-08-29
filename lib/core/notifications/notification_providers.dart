import 'package:life_os/core/notifications/notification_scheduler.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_providers.g.dart';

@Riverpod(keepAlive: true)
NotificationScheduler notificationScheduler(Ref ref) {
  return NotificationScheduler(ref.watch(appDatabaseProvider));
}
