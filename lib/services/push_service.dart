import '../services/graphql_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../logger_config.dart';

class PushService{

  // Get FCM Token
  static Future<String?> getFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      LoggerConfig().logger.i("FCM Token: $token");
      // You can now send this token to your backend for registration.
    } else {
      LoggerConfig().logger.e("Failed to get FCM token");
    }
    return token;
  }

  //mutate credential information
  // Request a day off for the employee
  static Future<bool> saveFCMToken(String employeeOid) async {
    String? fcmToken = await getFCMToken();
    String mutation =
    """
        mutation {
          saveFCMToken(employeeOid: "$employeeOid",
                        fcmToken: "$fcmToken",
                        )}
      """;
    final variables = {
      'employeeOid': employeeOid,
      'fcmToken': fcmToken,
    };
    // Call the mutate method from GraphQLService
    var result = await GraphQLService.mutate(
      mutation,
      variables: variables,
    );
    if (result.hasException) {
      LoggerConfig().logger.e("Error requesting day off: ${result.exception}");
      return false;  // Return false if there's an error
    } else {
      LoggerConfig().logger.i("Day off request status: ${result.data}");
      return true;  // Return true if successful
    }
  }
//push notification to supervisor
  static Future<String> sendPushToSupervisor(String employeeOid, String title, String message,String pageKey) async {
    String mutation =
    """
        mutation {
          sendNotificationToSupervisor(employeeOid: "$employeeOid",
                        title: "$title",
                        message: "$message",
                        pageKey: "$pageKey"
                        )}
      """;
    final variables = {
      'employeeOid': employeeOid,
      'title': title,
      'message': message,
      'pageKey': pageKey
    };
    // Call the mutate method from GraphQLService
    var result = await GraphQLService.mutate(
      mutation,
      variables: variables,
    );
    // Extract response data
    final data = result.data?['sendNotificationToSupervisor'];

    if (result.hasException) {
      LoggerConfig().logger.e("Error requesting day off: ${result.exception}");
      return data;  // Return false if there's an error
    } else {
      LoggerConfig().logger.i("Day off request status: ${result.data}");
      return data;  // Return true if successful
    }
  }


  //push notification to EmployeeId
  static Future<String> sendPushToEmployeeOid(String employeeOid, String title, String message,String pageKey) async {
    String mutation =
    """
        mutation {
          sendNotificationToEmployeeOid(
                        employeeOid: "$employeeOid",
                        title: "$title",
                        message: "$message",
                        pageKey: "$pageKey"

                        )}
      """;
    final variables = {
      'employeeOid': employeeOid,
      'title': title,
      'message': message,
      'pageKey': pageKey
    };
    // Call the mutate method from GraphQLService
    var result = await GraphQLService.mutate(
      mutation,
      variables: variables,
    );
    // Extract response data
    final data = result.data?['sendNotificationToEmployeeId'];

    if (result.hasException) {
      LoggerConfig().logger.e("Error Answering day off: ${result.exception}");
      return data;  // Return false if there's an error
    } else {
      LoggerConfig().logger.i("Day off Answering status: ${result.data}");
      return data;  // Return true if successful
    }
  }
}
