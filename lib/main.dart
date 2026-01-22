import 'package:flutter/material.dart';
import 'screens/input_screen.dart';

void main() {
  runApp(const QuickKakeiboApp());
}

class QuickKakeiboApp extends StatelessWidget {
  const QuickKakeiboApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quick Kakeibo',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const InputScreen(),
    );
  }
}
