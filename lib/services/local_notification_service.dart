import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static void initialize() {
    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    _notificationsPlugin.initialize(initializationSettings);
  }

  static void showNotification(RemoteMessage message) {
    final notification = message.notification;
    final androidDetails = AndroidNotificationDetails(
      'default_channel', // Channel ID
      'Default', // Channel name
      importance: Importance.high,
      priority: Priority.high,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    if (notification != null) {
      _notificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        notificationDetails,
      );
    }else{
      // If the notification fields are null, handle the data fields manually
      String? title = message.data['title'];
      String? body = message.data['message'];

      if (title != null && body != null) {
        // Show the notification using flutter_local_notifications
        _notificationsPlugin.show(
            0,
            title,
            body,
            notificationDetails,
            payload: 'Default_Sound',
        );
      }
    }
  }
}