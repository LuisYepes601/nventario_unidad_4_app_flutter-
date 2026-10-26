import 'package:flutter/material.dart';
import 'package:unidad_2/screens//home_screen.dart';
import 'package:unidad_2/util/notification_helper.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        scaffoldBackgroundColor: const Color(0xFFF2F6FB),
      ),
      home: const HomeScreen(),
    );
  }
}