import 'dart:async';
import 'package:flutter/material.dart';

typedef TimerFinishCallback = Function();
typedef TimerEditCallback = Function(Timer timer);

class CountdownTimer {
  CountdownTimer(
      {required this.lifetime,
      required this.onTimerFinish,
      required this.widgetToMarkFinished});

  final int lifetime;
  final TimerFinishCallback onTimerFinish;
  final TimerWidget widgetToMarkFinished;
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
      widgetToMarkFinished.markFinished();
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
    String a = (isDead ? Duration.zero : getTimeLeft()).toString();
    return a.substring(0, a.length - 3);
  }
}

class TimerWidget extends StatefulWidget {
  TimerWidget({
    super.key,
    required this.description,
    required this.lifetime,
    required this.onTimerFinish,
  });

  String description;
  final int lifetime;
  final TimerFinishCallback onTimerFinish;
  bool _isFinished = false;

  bool get isFinished => _isFinished;
  void markFinished() => _isFinished = true;

  @override
  State<TimerWidget> createState() => _TimerWidgetState(
      description: description,
      lifetime: lifetime,
      onTimerFinish: onTimerFinish,
      widgetToMarkFinished: this);
}

class _TimerWidgetState extends State<TimerWidget> {
  _TimerWidgetState(
      {required this.description,
      required int lifetime,
      required TimerFinishCallback onTimerFinish,
      required this.widgetToMarkFinished}) {
    _timer = CountdownTimer(
        lifetime: lifetime,
        onTimerFinish: onTimerFinish,
        widgetToMarkFinished: widgetToMarkFinished);
  }

  String description;
  TimerWidget widgetToMarkFinished;
  late CountdownTimer _timer;
  Timer? _updateTimer;

  void toggle() {
    if (_timer.isDead) return;
    if (_updateTimer == null) {
      _updateTimer = Timer.periodic(Duration.zero, (Timer t) {
        widgetToMarkFinished.isFinished ? null : setState(() {});
      });
      _timer.start();
    } else {
      setState(() {
        _updateTimer?.cancel();
        _updateTimer = null;
        _timer.stop();
      });
    }
  }

  void onEditItem(_TimerWidgetState tw, String newName) {
    setState(() {
      tw.description = newName;
    });
  }

  final TextEditingController _nameInputController = TextEditingController();
  final ButtonStyle yesStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20), primary: Colors.green);
  final ButtonStyle noStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20), primary: Colors.red);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
      onTap: () {
        String timerNameInput = "";
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Edit Timer'),
            content: TextField(
              key: const Key('timerNameInput'),
              onChanged: (value) {
                setState(() {
                  timerNameInput = value;
                });
              },
              controller: _nameInputController,
              decoration: const InputDecoration(hintText: 'Timer name'),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => {Navigator.pop(context)},
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => {
                  onEditItem(this, timerNameInput),
                  Navigator.pop(context),
                  print('Current Name: $description')
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
        _nameInputController.clear();
      },
      onLongPress: _timer.isPaused
          ? () {
              widgetToMarkFinished.markFinished();
              _timer.onTimerFinish();
            }
          : null,
      leading: IconButton(
        icon: Icon(_timer.isPaused
            ? Icons.play_circle_fill_rounded
            : Icons.pause_circle_filled_rounded),
        onPressed: () {
          toggle();
        },
        color: _timer.isPaused
            ? Theme.of(context).unselectedWidgetColor
            : Theme.of(context).indicatorColor,
      ),
      title: Text(
        description,
        style: Theme.of(context).textTheme.bodyText1,
      ),
      trailing: Text(
        _timer.toString(),
        style: Theme.of(context).textTheme.headline6,
      ),
    ));
  }
}
