import 'package:firebase_messaging/firebase_messaging.dart';
import 'local_notification_service.dart'; // Import the helper class

class NotificationHandler {
  static void initialize() {
    //Listen for foreground messages
    FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);
    // Listen for background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    requestNotificationPermissions();
  }
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling a background data message: ${message.data}');
    print('Handling a background noti message: ${message.notification?.title}, ${message.notification?.body}');
    // Show the notification using flutter_local_nostifications
    LocalNotificationService.showNotification(message);
  }
  static Future<void> _firebaseMessagingForegroundHandler(RemoteMessage message) async {
    print('Handling a foreground data message: ${message.data}');
    print('Handling a foreground noti message: ${message.notification?.title}, ${message.notification?.body}');
    // Show the notification using flutter_local_nostifications
    LocalNotificationService.showNotification(message);
  }
  static void requestNotificationPermissions() async {
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permissions');
    } else {
      print('User denied notification permissions');
    }
  }
}
