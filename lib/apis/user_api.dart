import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:twitter_clone/constants/constants.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/models/user_model.dart';

final userAPIProvider = Provider((ref) {
  return UserAPI(db: ref.watch(appwriteDatabaseProvider));
});

abstract class IUserAPI {
  FutureEitherVoid saveUserData(UserModel userModel);
}

class UserAPI implements IUserAPI {
  final Databases _db;

  UserAPI({required Databases db}) : _db = db;

  @override
  FutureEitherVoid saveUserData(UserModel userModel) async {
    try {
      final document = await _db.createDocument(
        databaseId: AppwriteConstants().databaseId,
        collectionId: AppwriteConstants().userCollectionId,
        documentId: userModel.uid,
        data: userModel.toMap(),
      );

      return right(null);
    } on AppwriteException catch (e, st) {
      return left(
        Failure(e.message ?? 'Some unexpected error happened', st),
      );
    } catch (e, st) {
      return left(
        Failure(e.toString() ?? 'Some unexpected error happened', st),
      );
    }
  }
}
