import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Configuración para Android
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración para iOS / macOS
    const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showBookRegisteredNotification(String bookTitle) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'books_channel',
      'Registro de Libros',
      channelDescription: 'Notificaciones sobre nuevos libros registrados',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '¡Libro Registrado! 📚',
      'El libro "$bookTitle" se ha guardado con éxito.',
      notificationDetails,
    );
  }
}