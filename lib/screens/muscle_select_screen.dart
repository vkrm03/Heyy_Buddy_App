import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dashboard_screen.dart';

class MuscleSelectScreen extends StatelessWidget {
  const MuscleSelectScreen({super.key});

  final List<Map<String, String>> muscles = const [
    {"name": "Chest", "image": "assets/chest.png"},
    {"name": "Back", "image": "assets/back.png"},
    {"name": "Shoulders", "image": "assets/shoulders.png"},
    {"name": "Arms", "image": "assets/arms.png"},
    {"name": "Abs", "image": "assets/abs.png"},
    {"name": "Legs", "image": "assets/legs.png"},
  ];

  Future<void> _saveWorkout(BuildContext context, String muscle) async {
    final url = Uri.parse("https://heyy-buddy-app.onrender.com/api/workouts");

    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"workoutType": muscle}),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.pink, Colors.redAccent, Colors.red],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
            child: const Text(
              "What muscle do you wanna burn today?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: muscles.length,
              itemBuilder: (context, index) {
                final muscle = muscles[index];
                return GestureDetector(
                  onTap: () => _saveWorkout(context, muscle["name"]!),
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.asset(muscle["image"]!, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        muscle["name"]!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
