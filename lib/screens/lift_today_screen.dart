import 'package:flutter/material.dart';
import 'muscle_select_screen.dart';

class LiftTodayScreen extends StatefulWidget {
  const LiftTodayScreen({super.key});

  @override
  State<LiftTodayScreen> createState() => _LiftTodayScreenState();
}

class _LiftTodayScreenState extends State<LiftTodayScreen>
    with TickerProviderStateMixin {
  late AnimationController _holdController;
  bool streakDone = false;
  int streakCount = 1;

  @override
  void initState() {
    super.initState();
    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // hold duration
    );
  }

  @override
  void dispose() {
    _holdController.dispose();
    super.dispose();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    _holdController.forward();
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    if (_holdController.value == 1.0) {
      // completed
      setState(() {
        streakDone = true;
      });

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MuscleSelectScreen()),
        );
      });
    } else {
      _holdController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: GestureDetector(
          onLongPressStart: _onLongPressStart,
          onLongPressEnd: _onLongPressEnd,
          child: streakDone
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: streakDone ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 400),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.greenAccent,
                  size: 120,
                ),
              ),
              const SizedBox(height: 20),
              AnimatedOpacity(
                opacity: streakDone ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                child: Text(
                  "Streak: $streakCount 🔥",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          )
              : Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: AnimatedBuilder(
                  animation: _holdController,
                  builder: (context, child) {
                    return CircularProgressIndicator(
                      value: _holdController.value,
                      strokeWidth: 10,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.orangeAccent),
                      backgroundColor: Colors.grey[800],
                    );
                  },
                ),
              ),
              const Icon(
                Icons.fitness_center,
                color: Colors.orange,
                size: 80,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
