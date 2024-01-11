import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/common/common.dart';
import 'package:twitter_clone/core/utils.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/home/views/home_view.dart';
import 'package:twitter_clone/features/profile/controller/user_profile_controller.dart';
import 'package:twitter_clone/theme/theme.dart';

class EditProfileView extends ConsumerStatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const EditProfileView());
  const EditProfileView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileViewState();
}

class _EditProfileViewState extends ConsumerState<EditProfileView> {
  late TextEditingController nameController;
  late TextEditingController bioContoller;
  File? bannerFile;
  File? profileFile;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
        text: ref.read(currentUserDetailsProvider).value?.name ?? '');
    bioContoller = TextEditingController(
        text: ref.read(currentUserDetailsProvider).value?.bio ?? '');
    bioContoller;
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    bioContoller.dispose();
  }

  void selectBannerImage() async {
    final banner = await pickImage();
    if (banner != null) {
      setState(() {
        bannerFile = banner;
      });
    }
  }

  void selectProfileImage() async {
    final profile = await pickImage();
    if (profile != null) {
      setState(() {
        profileFile = profile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModel = ref.watch(currentUserDetailsProvider).value;
    final isLoading = ref.watch(userProfileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {
              ref
                  .read(userProfileControllerProvider.notifier)
                  .updateUserProfile(
                    userModel: userModel!.copyWith(
                      name: nameController.text,
                      bio: bioContoller.text,
                    ),
                    context: context,
                    bannerFile: bannerFile,
                    profileFile: profileFile,
                  );
              Navigator.pop(context, HomeView.route());
            },
            child: const Text("Save"),
          ),
        ],
      ),
      body: isLoading || userModel == null
          ? const Loader()
          : Column(
              children: [
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: selectBannerImage,
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: bannerFile != null
                              ? Image.file(
                                  bannerFile!,
                                  fit: BoxFit.fitWidth,
                                )
                              : userModel.bannerPic!.isEmpty
                                  ? Container(color: Pallete.blueColor)
                                  : Image.network(
                                      userModel.bannerPic!,
                                      fit: BoxFit.fitWidth,
                                    ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: GestureDetector(
                          onTap: selectProfileImage,
                          child: profileFile != null
                              ? CircleAvatar(
                                  backgroundImage: FileImage(
                                    profileFile!,
                                  ),
                                  radius: 40,
                                )
                              : CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    userModel.profilePic!,
                                  ),
                                  radius: 40,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: "Name",
                    contentPadding: EdgeInsets.all(18),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: bioContoller,
                  decoration: const InputDecoration(
                    hintText: "Bio",
                    contentPadding: EdgeInsets.all(18),
                  ),
                  maxLines: 4,
                ),
              ],
            ),
    );
  }
}
