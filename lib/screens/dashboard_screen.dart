// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> workouts = [];
  String lastWorkout = "No workout yet";
  Map<String, int> countsByType = {};
  String favoriteWorkout = "None";

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  Future<void> _refreshAll() async {
    setState(() => _loading = true);
    await _fetchData();
    setState(() => _loading = false);
  }

  Future<void> _fetchData() async {
    final url = Uri.parse("https://heyy-buddy-app.onrender.com/api/workouts");
    try {
      final res = await http.get(url).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final workoutList = (data is Map && data["workouts"] is List)
            ? (data["workouts"] as List<dynamic>)
            : <dynamic>[];

        // sort ascending by date
        workoutList.sort((a, b) {
          final da = DateTime.parse(a['date']);
          final db = DateTime.parse(b['date']);
          return da.compareTo(db);
        });

        // last workout
        lastWorkout = workoutList.isNotEmpty
            ? (workoutList.last["workoutType"] ?? "Unknown")
            : "No workout yet";

        // counts by type
        countsByType = _countsByType(workoutList);

        // favorite workout
        if (countsByType.isNotEmpty) {
          final favoriteEntry =
          countsByType.entries.reduce((a, b) => a.value >= b.value ? a : b);
          favoriteWorkout = favoriteEntry.key;
        } else {
          favoriteWorkout = "None";
        }

        if (!mounted) return;
        setState(() {
          workouts = workoutList;
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load (${res.statusCode})")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error. Try again.")),
      );
    }
  }

  // ---------- Helpers ----------
  Map<String, int> _countsByType(List<dynamic> list) {
    final map = <String, int>{};
    for (final w in list) {
      final type = (w is Map && w["workoutType"] is String)
          ? w["workoutType"] as String
          : "Unknown";
      map[type] = (map[type] ?? 0) + 1;
    }
    return map;
  }

  // ---------- New Features: Badges + Levels ----------
  String _getLevel(int totalWorkouts) {
    if (totalWorkouts >= 100) return "Beast Mode";
    if (totalWorkouts >= 50) return "Pro";
    if (totalWorkouts >= 20) return "Intermediate";
    if (totalWorkouts >= 7) return "Rookie";
    return "Newbie";
  }

  // ---------- UI Widgets ----------
  Widget _statTile(String title, String value, Color start, Color end) {
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
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const SizedBox(height: 8),
          Text(value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    if (countsByType.isEmpty) {
      return [
        PieChartSectionData(
          value: 1,
          color: Colors.grey[800]!,
          radius: 60,
          title: 'No data',
          titleStyle: const TextStyle(color: Colors.white70, fontSize: 12),
        )
      ];
    }
    final total = countsByType.values.fold<int>(0, (a, b) => a + b);
    final entries = countsByType.entries.toList();
    return List<PieChartSectionData>.generate(entries.length, (i) {
      final e = entries[i];
      final value = e.value.toDouble();
      final percent = ((value / (total == 0 ? 1 : total)) * 100).round();
      final color = Colors.primaries[i % Colors.primaries.length].shade400;
      return PieChartSectionData(
        value: value,
        color: color,
        radius: 56,
        title: "$percent%",
        titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
        titlePositionPercentageOffset: 0.6,
      );
    });
  }

  Widget _buildPieCard() {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text("Workout Distribution",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 170,
              child: PieChart(
                PieChartData(
                  sections: _buildPieSections(),
                  centerSpaceRadius: 34,
                  sectionsSpace: 4,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: countsByType.entries.map((e) {
                final color = Colors
                    .primaries[
                countsByType.keys.toList().indexOf(e.key) %
                    Colors.primaries.length]
                    .shade400;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 12, height: 12, color: color),
                    const SizedBox(width: 6),
                    Text("${e.key} (${e.value})",
                        style: const TextStyle(color: Colors.white70)),
                  ],
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalWorkouts = workouts.length;
    final level = _getLevel(totalWorkouts);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Hey Buddy Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: _loading
          ? const Center(
          child: CircularProgressIndicator(color: Colors.orangeAccent))
          : RefreshIndicator(
        onRefresh: _refreshAll,
        color: Colors.orangeAccent,
        backgroundColor: Colors.black,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top stats
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _statTile("Last Workout", lastWorkout,
                      Colors.green, Colors.tealAccent),
                  _statTile("Total Workouts", "$totalWorkouts",
                      Colors.orange, Colors.redAccent),
                  _statTile("Favorite", favoriteWorkout,
                      Colors.indigo, Colors.blueAccent),
                  _statTile("Level", level,
                      Colors.purple, Colors.deepPurpleAccent),
                ],
              ),
              const SizedBox(height: 18),

              // Charts
              _buildPieCard(),
              const SizedBox(height: 18),

              // Distribution bars
              const Text("Workout Distribution (numbers)",
                  style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...countsByType.entries.map((e) {
                final percent =
                totalWorkouts == 0 ? 0.0 : e.value / totalWorkouts;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${e.key} (${e.value})",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: percent,
                        backgroundColor: Colors.grey[800],
                        valueColor: const AlwaysStoppedAnimation(
                            Colors.orangeAccent),
                        minHeight: 14,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
