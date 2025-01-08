import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static void initialize(Function(String?) onNotificationResponse) {
    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        String? payload = response.payload;
        onNotificationResponse(payload);
      },
    );
  }
  static Future<void> createNotificationChannel(String id, String name, String description) async {
    final androidChannel = AndroidNotificationChannel(
      id,
      name,
      description: description,
      importance: Importance.high,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }
  static void showNotification(RemoteMessage message, {String? payload}) {
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
        payload: payload ?? message.data['pageKey'], // Optional payload for navigation
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
            payload: payload ?? message.data['pageKey'], // Optional payload
        );
      }
    }
  }
}