import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'util/notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationHelper.inicializar();
  runApp(const InventarioApp());
}

class InventarioApp extends StatelessWidget {
  const InventarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InventarioApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}