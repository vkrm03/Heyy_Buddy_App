import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int streak = 0;
  String lastWorkout = "No workout yet";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final url = Uri.parse("http://10.0.2.2:5000/api/workouts");
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      if (data.isNotEmpty) {
        final workouts = data["workouts"] as List<dynamic>;
        final lastWorkoutType = workouts.isNotEmpty
            ? workouts.first["workoutType"] ?? "Unknown"
            : "No workout yet";

        setState(() {
          streak = data["streak"] ?? 0;
          lastWorkout = lastWorkoutType;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "🔥 Streak: $streak days",
              style: const TextStyle(
                color: Colors.orangeAccent,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "💪 Last workout: $lastWorkout",
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "(New day starts at 12 AM)",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
