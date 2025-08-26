import 'package:flutter/material.dart';
import 'screens/greeting_screen.dart';

void main() {
  runApp(const HeyBuddyApp());
}

class HeyBuddyApp extends StatelessWidget {
  const HeyBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hey Buddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.orange,
      ),
      home: const GreetingScreen(),
    );
  }
}
