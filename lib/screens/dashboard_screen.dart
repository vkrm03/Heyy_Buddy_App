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
  List<dynamic> workouts = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final url = Uri.parse("https://heyy-buddy-app.onrender.com/api/workouts");
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data.isNotEmpty) {
        final workoutList = data["workouts"] as List<dynamic>;
        final lastWorkoutType = workoutList.isNotEmpty
            ? workoutList.first["workoutType"] ?? "Unknown"
            : "No workout yet";

        setState(() {
          streak = data["streak"] ?? 0;
          lastWorkout = lastWorkoutType;
          workouts = workoutList;
        });
      }
    }
  }

  String getMotivationTitle() {
    if (streak >= 30) return "Titan Pro";
    if (streak >= 15) return "Iron Warrior";
    if (streak >= 7) return "Fitness Hero";
    if (streak >= 3) return "Getting Started";
    return "Newbie";
  }

  Map<String, int> _getWorkoutCounts() {
    Map<String, int> counts = {};
    for (var w in workouts) {
      String type = w["workoutType"] ?? "Unknown";
      counts[type] = (counts[type] ?? 0) + 1;
    }
    return counts;
  }

  double _getConsistencyPercent() {
    DateTime today = DateTime.now();
    List<DateTime> last30Days =
    List.generate(30, (i) => today.subtract(Duration(days: i)));
    Set<DateTime> workoutDates = workouts
        .map((w) => DateTime.parse(w["date"]))
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
    int workedDays = last30Days.where((d) => workoutDates.contains(d)).length;
    return (workedDays / 30) * 100;
  }

  List<DateTime> _getStreakDates() {
    return workouts.map<DateTime>((w) => DateTime.parse(w["date"])).toList();
  }

  @override
  Widget build(BuildContext context) {
    final workoutCounts = _getWorkoutCounts();
    final streakDates = _getStreakDates();
    final totalWorkouts = workouts.length;
    final consistency = _getConsistencyPercent();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: const Text("Heyy Buddy Dashboard"),
      ),
      body: workouts.isEmpty
          ? const Center(
        child: CircularProgressIndicator(color: Colors.orangeAccent),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Icon(Icons.local_fire_department,
                      color: Colors.orangeAccent, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    getMotivationTitle(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatTile(
                    "Current Streak", "$streak days", Colors.orange, Colors.redAccent),
                _buildStatTile(
                    "Last Workout", lastWorkout, Colors.green, Colors.tealAccent),
                _buildStatTile(
                    "Total Workouts", "$totalWorkouts", Colors.blue, Colors.lightBlueAccent),
                _buildStatTile(
                    "Consistency", "${consistency.toStringAsFixed(0)}%", Colors.purple, Colors.deepPurpleAccent),
              ],
            ),
            const SizedBox(height: 24),

            Text(
              "🔥 Streak Tracker",
              style: TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            const SizedBox(height: 12),
            _buildStreakGrid(streakDates),
            const SizedBox(height: 24),

            // Workout Distribution
            Text(
              "Workout Distribution",
              style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            const SizedBox(height: 12),
            ...workoutCounts.entries.map((e) {
              double percent = totalWorkouts == 0 ? 0 : e.value / totalWorkouts;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${e.key} (${e.value})",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percent,
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation(Colors.orangeAccent),
                      minHeight: 16,
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String title, String value, Color start, Color end) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(colors: [start, end]),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22)),
        ],
      ),
    );
  }

  Widget _buildStreakGrid(List<DateTime> dates) {
    DateTime today = DateTime.now();
    List<DateTime> last28Days =
    List.generate(28, (i) => today.subtract(Duration(days: 27 - i)));

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: last28Days.map((day) {
        bool didWorkout = dates.any((d) =>
        d.year == day.year && d.month == day.month && d.day == day.day);
        bool isSunday = day.weekday == DateTime.sunday;

        Color color;
        if (didWorkout) {
          color = Colors.greenAccent;
        } else if (isSunday) {
          color = Colors.blueAccent; // skipped Sunday
        } else {
          color = Colors.grey[800]!; // missed day
        }

        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }).toList(),
    );
  }
}
