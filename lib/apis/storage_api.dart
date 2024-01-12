import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:twitter_clone/constants/appwrite_constants.dart';
import 'package:twitter_clone/core/core.dart';

final storageAPIProvider = Provider((ref) {
  return StorageAPI(storage: ref.watch(appwriteStorageProvider));
});

class StorageAPI {
  final Storage _storage;
  var logger = Logger();

  StorageAPI({required Storage storage}) : _storage = storage;

  Future<List<String>> uploadImages(List<File> files) async {
    List<String> imageLinks = [];

    try {
      for (final file in files) {
        final uploadedImage = await _storage.createFile(
          bucketId: AppwriteConstants.imagesBucketId,
          fileId: ID.unique(),
          file: InputFile.fromPath(path: file.path),
        );

        imageLinks.add(AppwriteConstants.imageUrl(uploadedImage.$id));
      }
    } catch (e) {
      logger.e(e);
    }

    return imageLinks;
  }
}
