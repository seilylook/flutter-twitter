// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:twitter_clone/constants/assets_constants.dart';
import 'package:twitter_clone/core/enums/notification_type_enum.dart';
import 'package:twitter_clone/models/models.dart' as model;
import 'package:twitter_clone/theme/theme.dart';

class NotificationTile extends StatelessWidget {
  final model.Notification notification;

  const NotificationTile({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: getIcon(),
      title: Text(notification.text),
    );
  }

  Widget getIcon() {
    switch (notification.type) {
      case NotificationType.like:
        return SvgPicture.asset(
          AssetsConstants.likeFilledIcon,
          color: Pallete.redColor,
          height: 20,
        );

      case NotificationType.follow:
        return const Icon(
          Icons.person,
          color: Pallete.blueColor,
        );

      case NotificationType.retweet:
        return SvgPicture.asset(
          AssetsConstants.retweetIcon,
          color: Pallete.whiteColor,
        );

      case NotificationType.reply:
        return const Icon(
          Icons.comment,
          color: Pallete.whiteColor,
        );

      default:
        return const Icon(
          Icons.info,
          color: Pallete.blueColor,
        );
    }
  }
}
