import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:twitter_clone/common/common.dart';
import 'package:twitter_clone/constants/constants.dart';
import 'package:twitter_clone/features/home/views/home_view.dart';
import 'package:twitter_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitter_clone/features/tweet/widgets/tweet_card.dart';
import 'package:twitter_clone/models/models.dart';
import 'package:twitter_clone/theme/theme.dart';

class TwitterReplyView extends ConsumerWidget {
  static MaterialPageRoute route(TweetModel tweetModel) => MaterialPageRoute(
      builder: (context) => TwitterReplyView(tweetModel: tweetModel));
  final TweetModel tweetModel;

  const TwitterReplyView({
    super.key,
    required this.tweetModel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Twitter'),
      ),
      body: Column(
        children: [
          Flexible(
            child: Column(
              children: [
                TweetCard(tweetModel: tweetModel),
                Expanded(
                  child: ref.watch(getRepliesToTweetsProvider(tweetModel)).when(
                        data: (tweets) {
                          return ref.watch(getLatestTweetProvider).when(
                                data: (data) {
                                  final latestTweet =
                                      TweetModel.fromMap(data.payload);

                                  bool isTweetAlreadyPresent = false;

                                  for (final tweetModel in tweets) {
                                    if (tweetModel.id == latestTweet.id) {
                                      isTweetAlreadyPresent = true;
                                      break;
                                    }
                                  }

                                  if (!isTweetAlreadyPresent &&
                                      latestTweet.repliedTo == tweetModel.id) {
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
                                      final startingPoint = data.events[0]
                                          .lastIndexOf('documents.');
                                      final endPoint =
                                          data.events[0].lastIndexOf('.update');
                                      final targetTweetId = data.events[0]
                                          .substring(
                                              startingPoint + 10, endPoint);

                                      var newTweet = tweets
                                          .where((element) =>
                                              element.id == targetTweetId)
                                          .first;

                                      final removeTweetIndex =
                                          tweets.indexOf(newTweet);

                                      tweets.removeWhere(
                                        (element) =>
                                            element.id == targetTweetId,
                                      );

                                      newTweet =
                                          TweetModel.fromMap(data.payload);
                                      tweets.insert(removeTweetIndex, newTweet);
                                    }
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
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              maxLines: null,
              style: const TextStyle(fontSize: 16),
              onSubmitted: (value) {
                ref.read(tweetControllerProvider.notifier).shareTweet(
                  images: [],
                  text: value,
                  context: context,
                  repliedTo: tweetModel.id,
                );
                Navigator.pop(context, HomeView.route());
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(16.0),
                hintText: 'Type in your comment.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 2.0),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 10),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Pallete.greyColor,
              width: 0.3,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(25).copyWith(
                left: 15,
                right: 15,
              ),
              child: GestureDetector(
                onTap: () {},
                child: SvgPicture.asset(
                  AssetsConstants.galleryIcon,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25).copyWith(
                left: 15,
                right: 15,
              ),
              child: SvgPicture.asset(
                AssetsConstants.gifIcon,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25).copyWith(
                left: 15,
                right: 15,
              ),
              child: SvgPicture.asset(
                AssetsConstants.emojiIcon,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
