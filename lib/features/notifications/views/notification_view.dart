import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/common/common.dart';
import 'package:twitter_clone/constants/constants.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/notifications/controller/notification_controller.dart';
import 'package:twitter_clone/features/notifications/widgets/notification_tile.dart';
import 'package:twitter_clone/models/models.dart' as model;

class NotificationView extends ConsumerWidget {
  const NotificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: currentUser == null
          ? const Loader()
          : ref.watch(getNotificationsProvider(currentUser.uid)).when(
                data: (notifications) {
                  return ref.watch(getLatestNotificationProvider).when(
                        data: (data) {
                          if (data.events.contains(
                              'databases.*.collections.${AppwriteConstants.notificationColletionId}.documents.*.create')) {
                            final latest =
                                model.Notification.fromMap(data.payload);
                            if (latest.uid == currentUser.uid) {
                              notifications.insert(
                                0,
                                model.Notification.fromMap(data.payload),
                              );
                            }
                          }

                          return ListView.builder(
                            itemCount: notifications.length,
                            itemBuilder: (context, index) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: NotificationTile(
                                  notification: notifications[index]),
                            ),
                          );
                        },
                        error: (e, st) => ErrorText(error: e.toString()),
                        loading: () {
                          return ListView.builder(
                            itemCount: notifications.length,
                            itemBuilder: (context, index) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: NotificationTile(
                                  notification: notifications[index]),
                            ),
                          );
                        },
                      );
                },
                error: (error, st) => ErrorText(
                  error: error.toString(),
                ),
                loading: () => const Loader(),
              ),
    );
  }
}
