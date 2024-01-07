import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:twitter_clone/apis/apis.dart';
import 'package:twitter_clone/core/enums/tweet_type_enum.dart';
import 'package:twitter_clone/core/utils.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/models/models.dart';

var logger = Logger();

final tweetControllerProvider = StateNotifierProvider<TweetController, bool>(
  (ref) {
    logger.d(ref.watch(tweetAPIProvider));
    logger.d(ref.watch(storageAPIProvider));

    return TweetController(
      ref: ref,
      tweetAPI: ref.watch(tweetAPIProvider),
      storageAPI: ref.watch(storageAPIProvider),
    );
  },
);

final getTweetsProvider = FutureProvider((ref) {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getTweets();
});

final getRepliesToTweetsProvider =
    FutureProvider.family((ref, TweetModel tweetModel) {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  logger.d(tweetController);
  return tweetController.getRepliesToTweet(tweetModel);
});

final getLatestTweetProvider = StreamProvider.autoDispose((ref) {
  final tweetAPI = ref.watch(tweetAPIProvider);
  return tweetAPI.getLatestTweet();
});

final getTweetByIdProvider = FutureProvider.family((ref, String id) {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getTweetById(id);
});

class TweetController extends StateNotifier<bool> {
  final TweetAPI _tweetAPI;
  final StorageAPI _storageAPI;
  final Ref _ref;

  TweetController(
      {required Ref ref,
      required TweetAPI tweetAPI,
      required StorageAPI storageAPI})
      : _ref = ref,
        _tweetAPI = tweetAPI,
        _storageAPI = storageAPI,
        super(false);

  Future<List<TweetModel>> getTweets() async {
    final tweetList = await _tweetAPI.getTweets();
    return tweetList.map((tweet) => TweetModel.fromMap(tweet.data)).toList();
  }

  Future<TweetModel> getTweetById(String id) async {
    final tweet = await _tweetAPI.getTweetById(id);
    return TweetModel.fromMap(tweet.data);
  }

  void likeTweet(TweetModel tweetModel, UserModel userModel) async {
    List<String> likes = tweetModel.likes;

    if (tweetModel.likes.contains(userModel.uid)) {
      likes.remove(userModel.uid);
    } else {
      likes.add(userModel.uid);
    }

    tweetModel = tweetModel.copyWith(
      likes: likes,
    );

    final res = await _tweetAPI.likeTweet(tweetModel);
    res.fold((l) => null, (r) => null);
  }

  void reshareTweet(
    TweetModel tweetModel,
    UserModel currentUser,
    BuildContext context,
  ) async {
    tweetModel = tweetModel.copyWith(
      retweetedBy: currentUser.name,
      likes: [],
      commentIds: [],
      reshareCount: tweetModel.reshareCount + 1,
    );

    final res = await _tweetAPI.updateReshareCount(tweetModel);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) async {
        tweetModel = tweetModel.copyWith(
          id: ID.unique(),
          reshareCount: 0,
          tweetedAt: DateTime.now(),
        );

        final res2 = await _tweetAPI.shareTweet(tweetModel);

        res2.fold(
          (l) => showSnackBar(context, l.message),
          (r) => showSnackBar(
            context,
            "Retweet Success!",
          ),
        );
      },
    );
  }

  void shareTweet({
    required List<File> images,
    required String text,
    required BuildContext context,
    required String repliedTo,
  }) {
    if (text.isEmpty) {
      showSnackBar(context, "Please Enter the text!");
      return;
    }

    if (images.isNotEmpty) {
      _shareImageTweet(
        images: images,
        text: text,
        context: context,
        repliedTo: repliedTo,
      );
    } else {
      _shareTextTweet(
        text: text,
        context: context,
        repliedTo: repliedTo,
      );
    }
  }

  Future<List<TweetModel>> getRepliesToTweet(TweetModel tweetModel) async {
    final documents = await _tweetAPI.getRepliesFromTweet(tweetModel);

    return documents
        .map((document) => TweetModel.fromMap(document.data))
        .toList();
  }

  void _shareImageTweet({
    required List<File> images,
    required String text,
    required BuildContext context,
    required String repliedTo,
  }) async {
    state = true;
    final hashtags = _getHashtagFromText(text);
    String link = _getLinkFromText(text);
    final user = _ref.read(currentUserDetailsProvider).value!;
    final imageLinks = await _storageAPI.uploadImages(images);

    TweetModel tweetModel = TweetModel(
      text: text,
      hashtags: hashtags,
      link: link,
      imageLinks: imageLinks,
      uid: user.uid,
      tweetType: TweetType.image,
      tweetedAt: DateTime.now(),
      likes: const [],
      commentIds: const [],
      id: '',
      reshareCount: 0,
      retweetedBy: '',
      repliedTo: repliedTo,
    );

    final res = await _tweetAPI.shareTweet(tweetModel);

    res.fold((l) => showSnackBar(context, l.message), (r) => null);

    state = false;
  }

  void _shareTextTweet(
      {required String text,
      required BuildContext context,
      required String repliedTo}) async {
    state = true;
    final hashtags = _getHashtagFromText(text);
    String link = _getLinkFromText(text);
    final user = _ref.read(currentUserDetailsProvider).value!;

    TweetModel tweetModel = TweetModel(
      text: text,
      hashtags: hashtags,
      link: link,
      imageLinks: const [],
      uid: user.uid,
      tweetType: TweetType.text,
      tweetedAt: DateTime.now(),
      likes: const [],
      commentIds: const [],
      id: '',
      reshareCount: 0,
      retweetedBy: '',
      repliedTo: repliedTo,
    );

    final res = await _tweetAPI.shareTweet(tweetModel);
    state = false;

    res.fold((l) => showSnackBar(context, l.message), (r) => null);
  }

  String _getLinkFromText(String text) {
    List<String> wordsInSentence = text.split(' ');
    String link = '';

    for (String word in wordsInSentence) {
      if (word.startsWith('https://') || word.startsWith('www.')) {
        link = word;
      }
    }

    return link;
  }

  List<String> _getHashtagFromText(String text) {
    List<String> wordsInSentence = text.split(' ');
    List<String> hashtags = [];

    for (String word in wordsInSentence) {
      if (word.startsWith('#')) {
        hashtags.add(word);
      }
    }

    return hashtags;
  }
}
