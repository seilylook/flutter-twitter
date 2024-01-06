import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:twitter_clone/common/error_page.dart';
import 'package:twitter_clone/common/loading_page.dart';
import 'package:twitter_clone/constants/constants.dart';
import 'package:twitter_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitter_clone/features/tweet/widgets/tweet_card.dart';
import 'package:twitter_clone/models/models.dart';

var logger = Logger();

class TweetList extends ConsumerWidget {
  const TweetList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(getTweetsProvider).when(
          data: (tweets) {
            return ref.watch(getLatestTweetProvider).when(
                  data: (data) {
                    if (data.events.contains(
                      'databases.*.collections.${AppwriteConstants.tweetCollectionId}.documents.*.create',
                    )) {
                      logger.d(data.events);

                      tweets.insert(0, TweetModel.fromMap(data.payload));
                    } else if (data.events.contains(
                      'databases.*.collections.${AppwriteConstants.tweetCollectionId}.documents.*.update',
                    )) {
                      logger.d(data.events[0]);
                      // get id of tweet
                      final startingPoint =
                          data.events[0].lastIndexOf('documents.');
                      final endPoint = data.events[0].lastIndexOf('.update');
                      final targetTweetId = data.events[0]
                          .substring(startingPoint + 10, endPoint);

                      var newTweet = tweets
                          .where((element) => element.id == targetTweetId)
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
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
