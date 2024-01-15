import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppwriteConstants {
  static String projectId = dotenv.get('PUBLIC_PROJECT_ID');
  static String databaseId = dotenv.get('PUBLIC_DATABASE_ID');
  static String userCollectionId = dotenv.get('PUBLIC_USER_COLLECTION_ID');
  static String tweetCollectionId = dotenv.get('PUBLIC_TWEET_COLLECTION_ID');
  static String notificationColletionId =
      dotenv.get('PUBLIC_NOTIFICATION_COLLECTION_ID');
  static String imagesBucketId = dotenv.get('PUBLIC_IMAGES_BUCKET_ID');
  static String endPoint = dotenv.get('PUBLIC_BASE_URL');

  static String imageUrl(String imageId) =>
      '$endPoint/storage/buckets/$imagesBucketId/files/$imageId/view?project=$projectId&mode=admin';
}
