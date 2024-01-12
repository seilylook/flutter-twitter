// ignore_for_file: deprecated_member_use

import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:like_button/like_button.dart';
import 'package:twitter_clone/common/common.dart';
import 'package:twitter_clone/constants/assets_constants.dart';
import 'package:twitter_clone/core/enums/tweet_type_enum.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/profile/views/user_profile_view.dart';
import 'package:twitter_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitter_clone/features/tweet/views/twitter_reply_view.dart';
import 'package:twitter_clone/features/tweet/widgets/carousel_image.dart';
import 'package:twitter_clone/features/tweet/widgets/hashtag_text.dart';
import 'package:twitter_clone/features/tweet/widgets/tweet_icon_button.dart';
import 'package:twitter_clone/models/models.dart';
import 'package:twitter_clone/theme/pallete.dart';
import 'package:timeago/timeago.dart' as timeago;

class TweetCard extends ConsumerWidget {
  final TweetModel tweetModel;

  const TweetCard({
    super.key,
    required this.tweetModel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;

    return currentUser == null
        ? const SizedBox()
        : ref.watch(userDetailsProvider(tweetModel.uid)).when(
              data: (user) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, TwitterReplyView.route(tweetModel));
                  },
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(10),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context, UserProfileView.route(user));
                              },
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  user.profilePic!,
                                ),
                                radius: 40,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (tweetModel.retweetedBy.isNotEmpty)
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        AssetsConstants.retweetIcon,
                                        color: Pallete.blueColor,
                                        height: 20,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        ' ${tweetModel.retweetedBy} retweeted',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Pallete.blueColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                Row(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                        right: 5,
                                      ),
                                      child: Text(
                                        user.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '@${user.name} · ${timeago.format(
                                        tweetModel.tweetedAt,
                                        locale: 'en_short',
                                      )}',
                                      style: const TextStyle(
                                        color: Pallete.greyColor,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                if (tweetModel.repliedTo.isNotEmpty)
                                  ref
                                      .watch(getTweetByIdProvider(
                                          tweetModel.repliedTo))
                                      .when(
                                          data: (repliedToTweet) {
                                            final replyingToUser = ref
                                                .watch(userDetailsProvider(
                                                    repliedToTweet.uid))
                                                .value;

                                            return RichText(
                                              text: TextSpan(
                                                text: 'Replying to ',
                                                style: const TextStyle(
                                                  color: Pallete.greyColor,
                                                  fontSize: 16,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        '@${replyingToUser?.name}',
                                                    style: const TextStyle(
                                                      color: Pallete.blueColor,
                                                      fontSize: 16,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            );
                                          },
                                          error: (error, st) => ErrorText(
                                                error: error.toString(),
                                              ),
                                          loading: () => const SizedBox()),
                                HashtagText(text: tweetModel.text),
                                if (tweetModel.tweetType ==
                                    TweetType.image) ...[
                                  const SizedBox(height: 4),
                                  CarouselImage(
                                      imageLinks: tweetModel.imageLinks),
                                ],
                                if (tweetModel.link.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  AnyLinkPreview(
                                    displayDirection:
                                        UIDirection.uiDirectionHorizontal,
                                    link: 'https://${tweetModel.link}',
                                  ),
                                ],
                                Container(
                                  margin:
                                      const EdgeInsets.only(top: 10, right: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TweetIconButton(
                                        pathName: AssetsConstants.viewsIcon,
                                        text: (tweetModel.commentIds.length +
                                                tweetModel.reshareCount +
                                                tweetModel.likes.length)
                                            .toString(),
                                        onTap: () {},
                                      ),
                                      TweetIconButton(
                                        pathName: AssetsConstants.commentIcon,
                                        text: tweetModel.commentIds.length
                                            .toString(),
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              TwitterReplyView.route(
                                                  tweetModel));
                                        },
                                      ),
                                      TweetIconButton(
                                        pathName: AssetsConstants.retweetIcon,
                                        text:
                                            tweetModel.reshareCount.toString(),
                                        onTap: () {
                                          ref
                                              .read(tweetControllerProvider
                                                  .notifier)
                                              .reshareTweet(
                                                tweetModel,
                                                currentUser,
                                                context,
                                              );
                                        },
                                      ),
                                      LikeButton(
                                        size: 25,
                                        onTap: (isLiked) async {
                                          ref
                                              .read(tweetControllerProvider
                                                  .notifier)
                                              .likeTweet(
                                                tweetModel,
                                                currentUser,
                                              );

                                          return !isLiked;
                                        },
                                        isLiked: tweetModel.likes
                                            .contains(currentUser.uid),
                                        likeBuilder: (isLiked) {
                                          return isLiked
                                              ? SvgPicture.asset(
                                                  AssetsConstants
                                                      .likeFilledIcon,
                                                  color: Pallete.redColor,
                                                )
                                              : SvgPicture.asset(
                                                  AssetsConstants
                                                      .likeOutlinedIcon,
                                                  color: Pallete.greyColor,
                                                );
                                        },
                                        likeCount: tweetModel.likes.length,
                                        countBuilder:
                                            (likeCount, isLiked, text) {
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(left: 2),
                                            child: Text(
                                              text,
                                              style: TextStyle(
                                                color: isLiked
                                                    ? Pallete.redColor
                                                    : Pallete.whiteColor,
                                                fontSize: 16,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.share_outlined,
                                          size: 25,
                                          color: Pallete.greyColor,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 1),
                              ],
                            ),
                          )
                        ],
                      ),
                      const Divider(
                        color: Pallete.greyColor,
                      ),
                    ],
                  ),
                );
              },
              error: (error, stackTrace) => ErrorText(error: error.toString()),
              loading: () => const Loader(),
            );
  }
}
