import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> inicializar() async {
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);
  }

  static Future<void> notificarStockBajo(String nombre, int cantidad) async {
    const androidDetails = AndroidNotificationDetails(
      'stock_bajo_channel',
      'Alertas de stock',
      channelDescription: 'Notifica cuando un producto tiene stock bajo',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      nombre.hashCode,
      'Stock bajo',
      '"$nombre" quedó con $cantidad unidades',
      details,
    );
  }
}