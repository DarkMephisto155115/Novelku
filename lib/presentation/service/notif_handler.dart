import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHandler {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request notification permission
    await _firebaseMessaging.requestPermission();

    // Initialize flutter_local_notifications for Foreground notifications
    const AndroidInitializationSettings androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidInitSettings);

    await _flutterLocalNotificationsPlugin.initialize(initSettings);

    // Get Firebase Messaging token
    final fCMToken = await _firebaseMessaging.getToken();
    // print("Token: $fCMToken");

    _firebaseMessaging.subscribeToTopic('allUsers');
    // Handle notifications in Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // print('Message received in Foreground: ${message.notification?.title}');
      _showNotification(message);
    });

    // Handle notification when app is in Background and opened through notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // print('Notification opened in Background: ${message.notification?.title}');
      // Navigate or update UI
    });

    // Handle notification when app is Terminated
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        // print('Notification received when app was Terminated: ${message.notification?.title}');
        // Navigate or update UI
      }
    });
  }

  // Function to show notification
  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'your_channel_id', // channel ID
      'your_channel_name', // channel name
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
    );
  }
}
