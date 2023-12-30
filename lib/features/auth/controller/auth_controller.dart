import 'package:appwrite/models.dart' as model;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/auth_api.dart';
import 'package:twitter_clone/apis/user_api.dart';
import 'package:twitter_clone/core/utils.dart';
import 'package:twitter_clone/features/auth/view/login_view.dart';
import 'package:twitter_clone/features/home/view/home_view.dart';
import 'package:twitter_clone/models/user_model.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(
    authAPI: ref.watch(authAPIProvider),
    userAPI: ref.watch(userAPIProvider),
  );
});

final currentUserAccountProvider = FutureProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.currentUser();
});

class AuthController extends StateNotifier<bool> {
  final AuthAPI _authAPI;
  final UserAPI _userAPI;

  AuthController({
    required AuthAPI authAPI,
    required UserAPI userAPI,
  })  : _authAPI = authAPI,
        _userAPI = userAPI,
        super(false);

  Future<model.User?> currentUser() => _authAPI.currentUserAccount();

  void signUp({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _authAPI.signUp(
      email: email,
      password: password,
    );

    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) async {
        UserModel userModel = UserModel(
          email: email,
          name: getNameFromEmail(email),
          followers: const [],
          following: const [],
          profilePic: '',
          bannerPic: '',
          uid: r.$id,
          bio: '',
          isTwitterBlue: false,
        );
        final user_res = await _userAPI.saveUserData(userModel);

        user_res.fold((l) => showSnackBar(context, l.message), (r) {
          showSnackBar(context, 'Account is created! Please Log In.');
          Navigator.push(context, LoginView.route());
        });
      },
    );
  }

  void logIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true;

    final res = await _authAPI.logIn(
      email: email,
      password: password,
    );

    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => {
        showSnackBar(context, 'Login Success!'),
        Navigator.push(context, HomeView.route())
      },
    );
  }
}
