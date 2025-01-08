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
    FirebaseMessaging.onMessageOpenedApp
        .listen(_firebaseMessagingOpenedAppHandler);

    requestNotificationPermissions();
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    LoggerConfig()
        .logger
        .i('Handling a background data message: ${message.data}');
    LoggerConfig().logger.i(
        'Handling a background noti message: ${message.notification?.title}, ${message.notification?.body}');
    // Show the notification only if it's not already being handled
    if (message.notification != null) {
      LocalNotificationService.showNotification(message);
    }
  }

  static Future<void> _firebaseMessagingForegroundHandler(
      RemoteMessage message) async {
    LoggerConfig()
        .logger
        .i('Handling a foreground data message: ${message.data}');
    LoggerConfig().logger.i(
        'Handling a foreground noti message: ${message.notification?.title}, ${message.notification?.body}');
    // Show the notification and when tabbed then navigate using flutter_local_nostifications
    LocalNotificationService.showNotification(message);
  }

  // Handler for when the app is opened from the background (user tapped on the notification)
  static void _firebaseMessagingOpenedAppHandler(RemoteMessage message) {
    LoggerConfig().logger.i('App opened from notification: ${message.data}');
    LoggerConfig().logger.i(
        'Notification clicked: ${message.notification?.title}, ${message.notification?.body}');

    // Handle navigation based on notification data
    _handleNotificationNavigation(message.data['pageKey']);
  }

  static void requestNotificationPermissions() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
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
  static void _handleNotificationNavigation(String? pageKey) {
    // Check if the page is valid and change the selected key in AppConfig
    if (pageKey != null) {
      // For example, navigate to the "attendance" screen when "attendance" is passed
      AppConfig.selectedKeyNotifier.value = pageKey;
      LoggerConfig().logger.i('Navigated to page: $pageKey');
    }
  }
}
