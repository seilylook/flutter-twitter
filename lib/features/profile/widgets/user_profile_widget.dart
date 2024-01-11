import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:twitter_clone/common/error_page.dart';
import 'package:twitter_clone/common/loading_page.dart';
import 'package:twitter_clone/constants/constants.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/profile/controller/user_profile_controller.dart';
import 'package:twitter_clone/features/profile/views/edit_profile_view.dart';
import 'package:twitter_clone/features/profile/widgets/follow_count.dart';
import 'package:twitter_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitter_clone/features/tweet/widgets/tweet_card.dart';
import 'package:twitter_clone/models/models.dart';
import 'package:twitter_clone/theme/pallete.dart';

var logger = Logger();

class UserProfile extends ConsumerWidget {
  final UserModel userModel;
  const UserProfile({
    super.key,
    required this.userModel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;

    return currentUser == null
        ? const Loader()
        : NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 150,
                  floating: true,
                  snap: true,
                  flexibleSpace: Stack(
                    children: [
                      Positioned.fill(
                        child: userModel.bannerPic!.isEmpty
                            ? Container(
                                color: Pallete.blueColor,
                              )
                            : Image.network(
                                userModel.bannerPic!,
                                fit: BoxFit.fitWidth,
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            userModel.profilePic!,
                          ),
                          radius: 50,
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomRight,
                        margin: const EdgeInsets.all(20),
                        child: OutlinedButton(
                          autofocus: true,
                          onPressed: () {
                            if (currentUser.uid == userModel.uid) {
                              Navigator.push(context, EditProfileView.route());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(
                                width: 1.5,
                                color: Pallete.whiteColor,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                            ),
                          ),
                          child: Text(
                            currentUser.uid == userModel.uid
                                ? "Edit Profile"
                                : 'Follow',
                            style: const TextStyle(
                              color: Pallete.whiteColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(8),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Text(
                          userModel.name,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '@${userModel.name}',
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Pallete.blueColor,
                          ),
                        ),
                        Text(
                          userModel.bio!,
                          style: const TextStyle(
                            fontSize: 22,
                            color: Pallete.greyColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            FollowCount(
                              count: userModel.followers!.length,
                              text: 'Followers',
                            ),
                            const SizedBox(width: 15),
                            FollowCount(
                              count: userModel.following!.length,
                              text: 'Followings',
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Divider(
                          color: Pallete.whiteColor,
                        )
                      ],
                    ),
                  ),
                )
              ];
            },
            body: ref.watch(getUserTweetsProvider(userModel.uid)).when(
                  data: (tweets) {
                    return ref.watch(getLatestTweetProvider).when(
                          data: (data) {
                            if (data.events.contains(
                              'databases.*.collections.${AppwriteConstants.tweetCollectionId}.documents.*.create',
                            )) {
                              logger.d(data.events);

                              tweets.insert(
                                  0, TweetModel.fromMap(data.payload));
                            } else if (data.events.contains(
                              'databases.*.collections.${AppwriteConstants.tweetCollectionId}.documents.*.update',
                            )) {
                              logger.d(data.events[0]);
                              // get id of tweet
                              final startingPoint =
                                  data.events[0].lastIndexOf('documents.');
                              final endPoint =
                                  data.events[0].lastIndexOf('.update');
                              final targetTweetId = data.events[0]
                                  .substring(startingPoint + 10, endPoint);

                              var newTweet = tweets
                                  .where(
                                      (element) => element.id == targetTweetId)
                                  .first;

                              final removeTweetIndex = tweets.indexOf(newTweet);

                              tweets.removeWhere(
                                (element) => element.id == targetTweetId,
                              );

                              newTweet = TweetModel.fromMap(data.payload);
                              tweets.insert(removeTweetIndex, newTweet);
                            }

                            return ListView.builder(
                              itemCount: tweets.length,
                              itemBuilder: (BuildContext context, index) {
                                final tweet = tweets[index];
                                return TweetCard(tweetModel: tweet);
                              },
                            );
                          },
                          error: (error, stackTrace) =>
                              ErrorText(error: error.toString()),
                          loading: () {
                            return ListView.builder(
                              itemCount: tweets.length,
                              itemBuilder: (BuildContext context, index) {
                                final tweet = tweets[index];
                                return TweetCard(tweetModel: tweet);
                              },
                            );
                          },
                        );
                  },
                  error: (error, stackTrace) =>
                      ErrorText(error: error.toString()),
                  loading: () => const Loader(),
                ),
          );
  }
}
