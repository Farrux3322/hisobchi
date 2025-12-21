import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void showAwesomeNotification(RemoteMessage message) {
  print("===========================");
  print("Xabar keldi");
  print("===========================");

  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      channelKey: 'basic_channel',
      title: message.notification?.title ?? message.data['title'],
      body: message.notification?.body ?? message.data['body'],
      notificationLayout: NotificationLayout.Default,
      icon: 'resource://drawable/applogo',
      // largeIcon: 'resource://drawable/app_logo',  // Small icon for the status bar
      roundedLargeIcon: true,
    ),
  );
}
