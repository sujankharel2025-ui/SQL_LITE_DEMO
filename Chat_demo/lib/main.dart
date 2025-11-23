import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';
import 'utils/connectivity_service.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite database
  await DatabaseHelper.database;

  // Start listening to connectivity changes (auto-sync occurs inside)
  ConnectivityService.listen();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline Chat Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
