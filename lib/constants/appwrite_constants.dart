import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppwriteConstants {
  static String projectId = dotenv.get('PUBLIC_PROJECT_ID');
  static String databaseId = dotenv.get('PUBLIC_DATABASE_ID');
  static String userCollectionId = dotenv.get('PUBLIC_USER_COLLECTION_ID');
  static String endPoint = dotenv.get('PUBLIC_BASE_URL');
}
