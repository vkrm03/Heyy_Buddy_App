import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/lift_today_screen.dart';
import 'screens/muscle_select_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HeyBuddyApp());
}

class HeyBuddyApp extends StatelessWidget {
  const HeyBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hey Buddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(primaryColor: Colors.orange),
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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<String> _todayKey() async {
    final now = DateTime.now();
    return "${now.year.toString().padLeft(4,'0')}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}";
  }

  Future<void> _decide() async {
    final prefs = await SharedPreferences.getInstance();
    final today = await _todayKey();
    final last = prefs.getString("last_charged_date");
    if (last == today) {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    } else {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LiftTodayScreenWrapper()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: CircularProgressIndicator(color: Colors.orangeAccent)),
    );
  }
}

class LiftTodayScreenWrapper extends StatelessWidget {
  const LiftTodayScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return LiftTodayScreen(
      onStreakDone: () {
        if (!context.mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MuscleSelectScreen()));
      },
    );
  }
}
