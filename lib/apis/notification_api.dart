import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as model;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:twitter_clone/constants/appwrite_constants.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/models/models.dart';

final notificationAPIProvider = Provider((ref) {
  return NotificationAPI(
    db: ref.watch(appwriteDatabaseProvider),
    realtime: ref.watch(appwriteRealtimeProvider),
  );
});

abstract class INotificationAPI {
  FutureEitherVoid createNotification(Notification notification);
  Future<List<model.Document>> getNotifications(String uid);
  Stream<RealtimeMessage> getLatestNotification();
}

class NotificationAPI implements INotificationAPI {
  final Databases _db;
  final Realtime _realtime;

  NotificationAPI({required Databases db, required Realtime realtime})
      : _db = db,
        _realtime = realtime;

  @override
  FutureEitherVoid createNotification(Notification notification) async {
    try {
      await _db.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.notificationColletionId,
        documentId: ID.unique(),
        data: notification.toMap(),
      );

      return right(null);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? "Unexpected error happened", st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  Future<List<model.Document>> getNotifications(String uid) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.notificationColletionId,
      queries: [
        Query.equal('uid', uid),
      ],
    );

    return documents.documents;
  }

  @override
  Stream<RealtimeMessage> getLatestNotification() {
    return _realtime.subscribe([
      'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.notificationColletionId}.documents'
    ]).stream;
  }
}
