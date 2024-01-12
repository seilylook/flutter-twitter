import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:logger/logger.dart";
import "package:twitter_clone/common/common.dart";
import "package:twitter_clone/constants/constants.dart";
import "package:twitter_clone/features/profile/controller/user_profile_controller.dart";
import 'package:twitter_clone/features/profile/widgets/user_profile_widget.dart';
import "package:twitter_clone/models/user_model.dart";

var logger = Logger();

class UserProfileView extends ConsumerWidget {
  final UserModel user;
  static MaterialPageRoute route(UserModel user) =>
      MaterialPageRoute(builder: (context) => UserProfileView(user: user));

  const UserProfileView({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserModel copyOfUser = user;

    return Scaffold(
      body: ref.watch(getLatestUserProfileDataProvider).when(
            data: (data) {
              if (data.events.contains(
                'databases.*.collections.${AppwriteConstants.userCollectionId}.documents.${copyOfUser.uid}.update',
              )) {
                copyOfUser = UserModel.fromMap(data.payload);
                logger.d(copyOfUser);
              }

              return UserProfile(user: copyOfUser);
            },
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => UserProfile(user: copyOfUser),
          ),
    );
  }
}
