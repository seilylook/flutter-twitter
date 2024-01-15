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
        title: const Text('Tweet'),
      ),
      body: Column(
        children: [
          TweetCard(tweetModel: tweetModel),
          ref.watch(getRepliesToTweetsProvider(tweetModel)).when(
                data: (tweets) {
                  return ref.watch(getLatestTweetProvider).when(
                        data: (data) {
                          final latestTweet = TweetModel.fromMap(data.payload);

                          // check if incoming tweet repliesTo this current tweet
                          // and it doesn't exist in the current list of tweets to avoid duplication
                          if (latestTweet.repliedTo == tweetModel.id &&
                              !tweets.contains(latestTweet)) {
                            if (data.events.contains(
                                'databases.*.collections.${AppwriteConstants.tweetCollectionId}.documents.*.create')) {
                              tweets.insert(
                                  0, TweetModel.fromMap(data.payload));
                            } else if (data.events.contains(
                                'databases.*.collections.${AppwriteConstants.tweetCollectionId}.documents.*.update')) {
                              final startingPoint =
                                  data.events[0].lastIndexOf('documents.');
                              final endPoint =
                                  data.events[0].lastIndexOf('.update');
                              final tweetId = data.events[0]
                                  .substring(startingPoint + 10, endPoint);

                              var tweet = tweets
                                  .where((element) => element.id == tweetId)
                                  .first;
                              final tweetIndex = tweets.indexOf(tweet);
                              tweets.removeWhere(
                                  (element) => element.id == tweetId);
                              tweets.insert(tweetIndex, tweet);
                            }
                          }

                          return Expanded(
                            child: ListView.builder(
                              itemCount: tweets.length,
                              itemBuilder: (context, index) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: TweetCard(tweetModel: tweets[index]),
                              ),
                            ),
                          );
                        },
                        error: (e, st) => ErrorText(error: e.toString()),
                        loading: () {
                          return Expanded(
                            child: ListView.builder(
                              itemCount: tweets.length,
                              itemBuilder: (context, index) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: TweetCard(tweetModel: tweets[index]),
                              ),
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
        ],
      ),
      bottomNavigationBar: TextField(
        onSubmitted: (value) {
          ref.read(tweetControllerProvider.notifier).shareTweet(
            images: [],
            text: value,
            context: context,
            repliedTo: tweetModel.id,
          );
        },
        decoration: const InputDecoration(
          hintText: 'Tweet your reply',
          contentPadding: EdgeInsets.only(left: 20),
        ),
      ),
    );
  }
}
