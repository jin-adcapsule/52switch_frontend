import 'package:app52switch/screens/config_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'local_notification_service.dart'; // Import the helper class
import '../logger_config.dart';
class NotificationHandler {
  static void initialize() {
    //Listen for foreground messages
    FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);
    // Listen for background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // Listen for when the app is opened from a terminated state
    FirebaseMessaging.onMessageOpenedApp.listen(_firebaseMessagingOpenedAppHandler);


    requestNotificationPermissions();
  }
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    LoggerConfig().logger.i('Handling a background data message: ${message.data}');
    LoggerConfig().logger.i('Handling a background noti message: ${message.notification?.title}, ${message.notification?.body}');
    // Show the notification using flutter_local_nostifications
    LocalNotificationService.showNotification(message);
    // Navigate if needed when tapped
    _handleNotificationNavigation(message);
  }
  static Future<void> _firebaseMessagingForegroundHandler(RemoteMessage message) async {
    LoggerConfig().logger.i('Handling a foreground data message: ${message.data}');
    LoggerConfig().logger.i('Handling a foreground noti message: ${message.notification?.title}, ${message.notification?.body}');
    // Show the notification using flutter_local_nostifications
    LocalNotificationService.showNotification(message);
     // Navigate if needed when tapped
    _handleNotificationNavigation(message);
  }
  // Handler for when the app is opened from the background (user tapped on the notification)
  static void _firebaseMessagingOpenedAppHandler(RemoteMessage message) {
    LoggerConfig().logger.i('App opened from notification: ${message.data}');
    LoggerConfig().logger.i('Notification clicked: ${message.notification?.title}, ${message.notification?.body}');
    
    // Handle navigation based on the data in the notification
    _handleNotificationNavigation(message);
  }
  static void requestNotificationPermissions() async {
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      LoggerConfig().logger.i('User granted notification permissions');
    } else {
      LoggerConfig().logger.i('User denied notification permissions');
    }
  }

  // Function to handle navigation based on the notification data
  static void _handleNotificationNavigation(RemoteMessage message) {
    // Assuming the notification data includes a `page` field to navigate to
    String? page = message.data['page'];  // This can be customized to match your payload

    // Check if the page is valid and change the selected key in AppConfig
    if (page != null) {
      // For example, navigate to the "attendance" screen when "attendance" is passed
      AppConfig.selectedKeyNotifier.value = page;
      /*
      // If there's additional data (like a request ID), you can pass it as well
      if (page == 'supervisor') {
        String? requestKey = message.data['requestKey'];
        if (requestKey != null) {
          // Optionally, pass requestId to the screen if needed
          AppConfig.selectedKeyNotifier.value = 'supervisor';  // Ensure correct page
        }
      }
      */
    }
  }
}
