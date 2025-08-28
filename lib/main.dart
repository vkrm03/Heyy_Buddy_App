import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/dashboard_screen.dart';
import 'screens/lift_today_screen.dart';
import 'screens/muscle_select_screen.dart';

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
      home: const SplashDecider(),
    );
  }
}

class SplashDecider extends StatefulWidget {
  const SplashDecider({super.key});

  @override
  State<SplashDecider> createState() => _SplashDeciderState();
}

class _SplashDeciderState extends State<SplashDecider> {
  @override
  void initState() {
    super.initState();
    _checkTodayStreak();
  }

  Future<void> _checkTodayStreak() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastCheck = prefs.getString('last_streak_date');

    DateTime today = DateTime.now();
    String todayStr = "${today.year}-${today.month}-${today.day}";

    if (lastCheck == todayStr) {
      // Already checked in today → skip to dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      // Not checked in today → go to streak check screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LiftTodayScreenWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(color: Colors.orangeAccent),
      ),
    );
  }
}

class LiftTodayScreenWrapper extends StatelessWidget {
  const LiftTodayScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return LiftTodayScreen(
      onStreakDone: () async {
        DateTime today = DateTime.now();
        String todayStr = "${today.year}-${today.month}-${today.day}";
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_streak_date', todayStr);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MuscleSelectScreen()),
        );
      },
    );
  }
}
