import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/apis.dart';
import 'package:twitter_clone/models/models.dart';

// API 요청에 따른 응답 지켜보는 Provider
// 응답이 온다면 notifier를 통해 알 수 있다.
final userProfileControllerProvider = StateNotifierProvider((ref) {
  return UserProfileController(tweetAPI: ref.watch(tweetAPIProvider));
});

// Notifier를 지켜보고 있는 Provider
// View/Widget 에서 지켜보고 있는 Provider이다.
// 이 Provider에서 데이터 변화를 알 수 있고 && 사용할 수 있다.
final getUserTweetsProvider = FutureProvider.family((ref, String uid) {
  final userProfileController =
      ref.watch(userProfileControllerProvider.notifier);
  return userProfileController.getUserTweets(uid);
});

final class UserProfileController extends StateNotifier<bool> {
  final TweetAPI _tweetAPI;

  UserProfileController({required TweetAPI tweetAPI})
      : _tweetAPI = tweetAPI,
        super(false);

  Future<List<TweetModel>> getUserTweets(String uid) async {
    final tweets = await _tweetAPI.getUserTweets(uid);
    return tweets.map((e) => TweetModel.fromMap(e.data)).toList();
  }
}
