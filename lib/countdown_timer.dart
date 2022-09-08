import 'dart:async';
import 'package:flutter/material.dart';

typedef TimerFinishCallback = Function();

class CountdownTimer {
  CountdownTimer({required this.lifetime, required this.onTimerFinish});

  final int lifetime;
  final TimerFinishCallback onTimerFinish;
  final _stopwatch = Stopwatch();
  bool isDead = false;
  Timer? _timer;

  Duration getTimeLeft() {
    return Duration(seconds: lifetime) - _stopwatch.elapsed;
  }

  void start() {
    if (isDead) return;
    _stopwatch.start();
    _timer?.cancel();
    _timer = Timer(getTimeLeft(), () {
      stop();
      isDead = true;
      onTimerFinish();
    });
  }

  void stop() {
    _timer?.cancel();
    _stopwatch.stop();
  }

  bool get isPaused => !_stopwatch.isRunning;

  @override
  String toString() {
    String a = (isDead
      ? Duration.zero
      : getTimeLeft()
    ).toString();
    return a.substring(0, a.length - 3);
  }
}

class TimerWidget extends StatefulWidget {
  const TimerWidget({
    required this.description, 
    required this.lifetime, 
    required this.onTimerFinish
  });

  final String description;
  final int lifetime;
  final TimerFinishCallback onTimerFinish;

  @override
  State<TimerWidget> createState() => _TimerWidgetState(
    description: description, 
    lifetime: lifetime, 
    onTimerFinish: onTimerFinish
  );
}

class _TimerWidgetState extends State<TimerWidget> {

  _TimerWidgetState({
    required this.description, 
    required int lifetime, 
    required TimerFinishCallback onTimerFinish
  }) {
    _timer = CountdownTimer(lifetime: lifetime, onTimerFinish: onTimerFinish);
  }

  String description;
  late CountdownTimer _timer;
  Timer? _updateTimer;

  void toggle() {
    if (_timer.isDead) return;
    if (_updateTimer == null) {
      _updateTimer = Timer.periodic(
        Duration.zero,
        (Timer t) => setState(() {})
      );
      _timer.start();
    } else {
      _updateTimer?.cancel();
      _updateTimer = null;
      _timer.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: toggle,
      onLongPress: _timer.isPaused
        ? _timer.onTimerFinish
        : null,
      leading: Text(description),
      trailing: Text(_timer.toString()),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Timer Test',
    home: Scaffold(
      body: Center(
        child: TimerWidget(
          description: 'my timer',
          lifetime: 3, 
          onTimerFinish: () => print('Timer finished!')
        ),
      ),
    )
  ));
}