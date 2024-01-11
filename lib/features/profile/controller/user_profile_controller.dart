import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/apis.dart';
import 'package:twitter_clone/core/utils.dart';
import 'package:twitter_clone/models/models.dart';

// API 요청에 따른 응답 지켜보는 Provider
// 응답이 온다면 notifier를 통해 알 수 있다.
final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
  return UserProfileController(
    tweetAPI: ref.watch(tweetAPIProvider),
    storageAPI: ref.watch(storageAPIProvider),
    userAPI: ref.watch(userAPIProvider),
  );
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
  final StorageAPI _storageAPI;
  final UserAPI _userAPI;

  UserProfileController(
      {required TweetAPI tweetAPI,
      required StorageAPI storageAPI,
      required UserAPI userAPI})
      : _tweetAPI = tweetAPI,
        _storageAPI = storageAPI,
        _userAPI = userAPI,
        super(false);

  Future<List<TweetModel>> getUserTweets(String uid) async {
    final tweets = await _tweetAPI.getUserTweets(uid);
    return tweets.map((e) => TweetModel.fromMap(e.data)).toList();
  }

  void updateUserProfile(
      {required UserModel userModel,
      required BuildContext context,
      required File? bannerFile,
      required File? profileFile}) async {
    state = true;
    if (bannerFile != null) {
      final bannerUrl = await _storageAPI.uploadImages([bannerFile]);
      userModel = userModel.copyWith(
        bannerPic: bannerUrl[0],
      );
    }

    if (profileFile != null) {
      final profileUrl = await _storageAPI.uploadImages([profileFile]);
      userModel = userModel.copyWith(
        profilePic: profileUrl[0],
      );
    }

    final res = await _userAPI.updateUserData(userModel);

    state = false;

    res.fold(
        (l) => showSnackBar(context, l.message), (r) => Navigator.pop(context));
  }
}
