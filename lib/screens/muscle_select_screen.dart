import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';

class MuscleSelectScreen extends StatefulWidget {
  const MuscleSelectScreen({super.key});

  @override
  State<MuscleSelectScreen> createState() => _MuscleSelectScreenState();
}

class _MuscleSelectScreenState extends State<MuscleSelectScreen> {
  final List<Map<String, String>> muscles = const [
    {"name": "Chest", "image": "assets/chest.png"},
    {"name": "Back", "image": "assets/back.png"},
    {"name": "Shoulders", "image": "assets/shoulders.png"},
    {"name": "Arms", "image": "assets/arms.png"},
    {"name": "Abs", "image": "assets/abs.png"},
    {"name": "Legs", "image": "assets/legs.png"},
    {"name": "Rest", "image": "assets/rest.png"},
    {"name": "Overall", "image": "assets/overall.png"},
  ];

  bool _saving = false;

  Future<void> _saveWorkout(String muscle) async {
    setState(() => _saving = true);
    final url = Uri.parse("https://heyy-buddy-app.onrender.com/api/workouts");

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"workoutType": muscle}),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        // persist last_charged_date only after successful save
        final prefs = await SharedPreferences.getInstance();
        final now = DateTime.now();
        final key = "${now.year.toString().padLeft(4,'0')}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}";
        await prefs.setString("last_charged_date", key);

        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Save failed (${res.statusCode})")));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Network error. Try again.")));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Choose Muscle"), backgroundColor: Colors.deepPurple),
      body: Column(
        children: [
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(colors: [Colors.pink, Colors.redAccent, Colors.red], begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
              child: const Text(
                "What muscle do you wanna burn today?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16),
              itemCount: muscles.length,
              itemBuilder: (context, index) {
                final muscle = muscles[index];
                return GestureDetector(
                  onTap: _saving ? null : () => _saveWorkout(muscle["name"]!),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Image.asset(muscle["image"]!, fit: BoxFit.contain),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(muscle["name"]!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_saving)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                CircularProgressIndicator(color: Colors.orangeAccent),
                SizedBox(width: 12),
                Text("Saving...", style: TextStyle(color: Colors.white70)),
              ]),
            ),
        ],
      ),
    );
  }
}
