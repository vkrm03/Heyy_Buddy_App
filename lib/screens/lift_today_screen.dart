import 'package:flutter/material.dart';

class LiftTodayScreen extends StatefulWidget {
  final VoidCallback? onStreakDone;
  const LiftTodayScreen({super.key, this.onStreakDone});

  @override
  State<LiftTodayScreen> createState() => _LiftTodayScreenState();
}

class _LiftTodayScreenState extends State<LiftTodayScreen> with TickerProviderStateMixin {
  late AnimationController _holdController;
  late AnimationController _textController;

  bool _streakDoneUI = false;
  bool _completedOnce = false;

  @override
  void initState() {
    super.initState();
    _holdController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _textController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..forward();
  }

  @override
  void dispose() {
    _holdController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    if (_completedOnce) return;
    _holdController.forward();
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    if (_completedOnce) return;

    if (_holdController.value >= 0.999) {
      setState(() => _streakDoneUI = true);
      _completedOnce = true;
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        widget.onStreakDone?.call();
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
          child: _streakDoneUI
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              AnimatedScale(scale: 1.2, duration: Duration(milliseconds: 300), child: Icon(Icons.check_circle, color: Colors.greenAccent, size: 120)),
              SizedBox(height: 20),
              Text("Yahh Buddy 🔥!", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
            ],
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _textController,
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(colors: [Colors.orangeAccent, Colors.redAccent], begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(bounds),
                  child: const Text("Charge Your Day ⚡", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 36),
              Stack(
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
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                          backgroundColor: Colors.grey,
                        );
                      },
                    ),
                  ),
                  const Icon(Icons.fitness_center, color: Colors.orange, size: 80),
                ],
              ),
              const SizedBox(height: 14),
              const Text("Hold to take charge today", style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
