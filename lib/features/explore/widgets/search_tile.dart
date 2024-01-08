import 'package:flutter/material.dart';
import 'package:twitter_clone/features/profile/views/user_profile_view.dart';
import 'package:twitter_clone/models/models.dart';
import 'package:twitter_clone/theme/pallete.dart';

class SearchTile extends StatelessWidget {
  final UserModel userModel;

  const SearchTile({
    super.key,
    required this.userModel,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(context, UserProfileView.route(userModel));
      },
      leading: CircleAvatar(
        backgroundImage: NetworkImage(userModel.profilePic!),
        radius: 30,
      ),
      title: Text(
        userModel.name,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '@${userModel.name}',
            style: const TextStyle(
              fontSize: 16,
              color: Pallete.blueColor,
            ),
          ),
          Text(
            userModel.bio!,
            style: const TextStyle(
              fontSize: 16,
              color: Pallete.whiteColor,
            ),
          ),
        ],
      ),
    );
  }
}
