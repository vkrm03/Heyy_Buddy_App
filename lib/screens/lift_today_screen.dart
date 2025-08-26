import 'package:flutter/material.dart';
import 'muscle_select_screen.dart';

class LiftTodayScreen extends StatefulWidget {
  const LiftTodayScreen({super.key});

  @override
  State<LiftTodayScreen> createState() => _LiftTodayScreenState();
}

class _LiftTodayScreenState extends State<LiftTodayScreen> {
  bool streakDone = false;

  void _markStreak() {
    setState(() {
      streakDone = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MuscleSelectScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: GestureDetector(
          onLongPress: _markStreak,
          child: streakDone
              ? const Icon(Icons.check_circle,
              color: Colors.greenAccent, size: 120)
              : const Icon(Icons.fitness_center,
              color: Colors.orange, size: 120),
        ),
      ),
    );
  }
}
