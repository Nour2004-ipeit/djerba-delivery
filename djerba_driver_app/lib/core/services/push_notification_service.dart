import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import '../network/dio_client.dart';

class PushNotificationService {
  static Future<void> initialize({Function(String, String)? onNotification}) async {
    if (kIsWeb) {
      // FCM requires specific web configuration; skip on web dev
      return;
    }

    try {
      final messaging = FirebaseMessaging.instance;

      // 1. Request permissions
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
        
        // 2. Get the token
        String? token = await messaging.getToken();
        print('FCM Token: $token');
        
        if (token != null) {
          await _sendTokenToServer(token);
        }

        // 3. Listen to token updates
        messaging.onTokenRefresh.listen((newToken) {
          _sendTokenToServer(newToken);
        });

        // 4. Handle incoming messages when the app is in the foreground
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print('Received a message while in the foreground!');
          print('Message data: ${message.data}');

          if (message.notification != null) {
            print('Message also contained a notification: ${message.notification}');
            if (onNotification != null) {
              onNotification(message.notification?.title ?? 'New Notification', message.notification?.body ?? '');
            }
          }
        });
      } else {
        print('User declined or has not accepted permission');
      }
    } catch (e) {
      print('PushNotificationService initialization error: $e');
    }
  }

  static Future<void> _sendTokenToServer(String token) async {
    try {
      final dio = DioClient().dio;
      await dio.put('/users/me/fcm-token', data: {'fcmToken': token});
      print('FCM Token successfully synced with backend.');
    } catch (e) {
      print('Failed to sync FCM token: $e');
    }
  }
}
