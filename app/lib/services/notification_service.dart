import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Must be a top-level function: the platform invokes it in a background isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No Firebase.initializeApp() needed here on Android; the plugin handles it.
  debugPrint('Notification reçue en arrière-plan: ${message.messageId}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'cvcp_general',
    'Actualités du Centre',
    description: 'Notifications des actualités et événements du CENTRE DE PRIÈRE CHRIST VAINQUEUR',
    importance: Importance.high,
  );

  static const _networkTimeout = Duration(seconds: 10);

  Future<void> init() async {
    await _messaging
        .requestPermission(alert: true, badge: true, sound: true)
        .timeout(_networkTimeout);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    // Toutes les news/événements publiés sont diffusés sur ces topics.
    await _messaging.subscribeToTopic('actualites').timeout(_networkTimeout);
    await _messaging.subscribeToTopic('evenements').timeout(_networkTimeout);

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
