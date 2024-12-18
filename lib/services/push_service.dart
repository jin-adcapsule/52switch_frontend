import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/graphql_service.dart';
import '../screens/config_screen.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class PushService{

  // Get FCM Token
  static Future<String?> getFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      print("FCM Token: $token");
      // You can now send this token to your backend for registration.
    } else {
      print("Failed to get FCM token");
    }
    return token;
  }

  //mutate credential information
  // Request a day off for the employee
  static Future<bool> saveFCMToken(String objectId) async {
    String? fcmToken = await getFCMToken();
    String mutation =
    """
        mutation {
          saveFCMToken(objectId: "$objectId",
                        fcmToken: "$fcmToken",
                        )}
      """;
    final variables = {
      'objectId': objectId,
      'fcmToken': fcmToken,
    };
    // Call the mutate method from GraphQLService
    var result = await GraphQLService.mutate(
      mutation,
      variables: variables,
    );
    print(variables);
    if (result.hasException) {
      print("Error requesting day off: ${result.exception}");
      return false;  // Return false if there's an error
    } else {
      print("Day off request status: ${result.data}");
      return true;  // Return true if successful
    }
  }
//push notification to supervisor
  static Future<String> sendPushToSupervisor(String objectId, String title, String message) async {
    String mutation =
    """
        mutation {
          sendNotificationToSupervisor(objectId: "$objectId",
                        title: "$title",
                        message: "$message"
                        )}
      """;
    final variables = {
      'objectId': objectId,
      'title': title,
      'message': message
    };
    // Call the mutate method from GraphQLService
    var result = await GraphQLService.mutate(
      mutation,
      variables: variables,
    );
    print(variables);
    // Extract response data
    final data = result.data?['sendNotificationToSupervisor'];

    if (result.hasException) {
      print("Error requesting day off: ${result.exception}");
      return data;  // Return false if there's an error
    } else {
      print("Day off request status: ${result.data}");
      return data;  // Return true if successful
    }
  }


  //push notification to EmployeeId
  static Future<String> sendPushToEmployeeId(int employeeId, String title, String message) async {
    String mutation =
    """
        mutation {
          sendNotificationToEmployeeId(employeeId: $employeeId,
                        title: "$title",
                        message: "$message"
                        )}
      """;
    final variables = {
      'employeeId': employeeId,
      'title': title,
      'message': message
    };
    // Call the mutate method from GraphQLService
    var result = await GraphQLService.mutate(
      mutation,
      variables: variables,
    );
    print(variables);
    // Extract response data
    final data = result.data?['sendNotificationToEmployeeId'];

    if (result.hasException) {
      print("Error requesting day off: ${result.exception}");
      return data;  // Return false if there's an error
    } else {
      print("Day off request status: ${result.data}");
      return data;  // Return true if successful
    }
  }
}
