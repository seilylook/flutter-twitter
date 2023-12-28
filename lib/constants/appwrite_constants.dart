import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppwriteConstants {
  String projectId = dotenv.get('PUBLIC_PROJECT_ID');
  String databaseId = dotenv.get('PUBLIC_DATABASE_ID');
  String endPoint = dotenv.get('PUBLIC_BASE_URL');
}
