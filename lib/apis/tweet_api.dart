import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as model;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:twitter_clone/constants/constants.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/models/models.dart';

final tweetAPIProvider = Provider((ref) {
  return TweetAPI(
    db: ref.watch(appwriteDatabaseProvider),
    realtime: ref.watch(appwriteRealtimeProvider),
  );
});

abstract class ITweetAPI {
  FutureEither<model.Document> shareTweet(TweetModel tweet);
  Future<List<model.Document>> getTweets();
  Stream<RealtimeMessage> getLatestTweet();
  FutureEither<model.Document> likeTweet(TweetModel tweetModel);
  FutureEither<model.Document> updateReshareCount(TweetModel tweetModel);
}

class TweetAPI implements ITweetAPI {
  final Databases _db;
  final Realtime _realtime;

  TweetAPI({required Databases db, required Realtime realtime})
      : _db = db,
        _realtime = realtime;

  @override
  FutureEither<model.Document> shareTweet(TweetModel tweetModel) async {
    try {
      final document = await _db.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.tweetCollectionId,
        documentId: ID.unique(),
        data: tweetModel.toMap(),
      );

      return right(document);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? 'Unexpected error happened', st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  Future<List<model.Document>> getTweets() async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.tweetCollectionId,
      queries: [
        Query.orderDesc('tweetedAt'),
      ],
    );

    return documents.documents;
  }

  @override
  Stream<RealtimeMessage> getLatestTweet() {
    return _realtime.subscribe([
      'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.tweetCollectionId}.documents'
    ]).stream;
  }

  @override
  FutureEither<model.Document> likeTweet(TweetModel tweetModel) async {
    try {
      final document = await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.tweetCollectionId,
        documentId: tweetModel.id,
        data: {
          'likes': tweetModel.likes,
        },
      );

      return right(document);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? 'Unexpected error happened', st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureEither<model.Document> updateReshareCount(TweetModel tweetModel) async {
    try {
      final document = await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.tweetCollectionId,
        documentId: tweetModel.id,
        data: {
          'reshareCount': tweetModel.reshareCount,
        },
      );

      return right(document);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? "Unexpeted error happened", st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }
}
