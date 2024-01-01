import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/common/common.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/theme/pallete.dart';

class CreateTweetView extends ConsumerStatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => const CreateTweetView());

  const CreateTweetView({super.key});

  @override
  ConsumerState<CreateTweetView> createState() => _CreateTweetViewState();
}

class _CreateTweetViewState extends ConsumerState<CreateTweetView> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.close,
            size: 30,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 15,
            ),
            child: RoundedSmallButton(
              label: 'Tweet',
              onTap: () {},
              backgroundColor: Pallete.blueColor,
              textColor: Pallete.whiteColor,
            ),
          ),
        ],
      ),
      body: currentUser == null
          ? const Text('No user data')
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(currentUser.profilePic!),
                          radius: 30,
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
