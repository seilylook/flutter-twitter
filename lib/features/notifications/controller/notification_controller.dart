import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:twitter_clone/apis/notification_api.dart';
import 'package:twitter_clone/core/enums/notification_type_enum.dart';
import 'package:twitter_clone/models/notification_model.dart' as model;

var logger = Logger();

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, bool>((ref) {
  return NotificationController(
      notificationAPI: ref.watch(notificationAPIProvider));
});

final getNotificationsProvider = FutureProvider.family((ref, String uid) async {
  final notificationController =
      ref.watch(notificationControllerProvider.notifier);
  return notificationController.getNotifications(uid);
});

final getLatestNotificationProvider = StreamProvider((ref) {
  final notificationAPI = ref.watch(notificationAPIProvider);
  return notificationAPI.getLatestNotification();
});

class NotificationController extends StateNotifier<bool> {
  final NotificationAPI _notificationAPI;

  NotificationController({
    required NotificationAPI notificationAPI,
  })  : _notificationAPI = notificationAPI,
        super(false);

  void createNotification({
    required String text,
    required String postId,
    required NotificationType notificationType,
    required String uid,
  }) async {
    final notification = model.Notification(
      id: '',
      text: text,
      uid: uid,
      type: notificationType,
      postId: postId,
    );

    final res = await _notificationAPI.createNotification(notification);
    logger.d(res);
    res.fold((l) => null, (r) => null);
  }

  Future<List<model.Notification>> getNotifications(String uid) async {
    final notifications = await _notificationAPI.getNotifications(uid);
    logger.d(notifications);
    return notifications
        .map((e) => model.Notification.fromMap(e.data))
        .toList();
  }
}
