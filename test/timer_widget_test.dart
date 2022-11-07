import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:to_dont_list/main.dart';
import 'package:to_dont_list/countdown_timer.dart';

void main() {
  test('CountdownTimer starts at the correct time', () {
    Duration testDuration = const Duration(seconds: 5);
    CountdownTimer ct = CountdownTimer(
        lifetime: testDuration.inSeconds,
        onTimerFinish: () {},
        widgetToMarkFinished: TimerWidget(
            description: 'test widget',
            lifetime: testDuration.inSeconds,
            onTimerFinish: () {}));

    expect(ct.getTimeLeft(), testDuration);
  });

  test('CountdownTimer marks parent TimerWidget as complete after finishing',
      () {
    Duration testDuration = const Duration(seconds: 5);
    TimerWidget tw = TimerWidget(
        description: 'test widget',
        lifetime: testDuration.inSeconds,
        onTimerFinish: () {});
    CountdownTimer ct = CountdownTimer(
        lifetime: testDuration.inSeconds,
        onTimerFinish: () {},
        widgetToMarkFinished: tw);

    expect(tw.isFinished, false);

    ct.start();
    Timer(testDuration + const Duration(milliseconds: 1), () {
      expect(tw.isFinished, true);
    });
  });

  testWidgets('Clicking and typing adds timer to list', (tester) async {
    String testString = 'new timer';
    String testTime = '2';

    await tester.pumpWidget(const MaterialApp(home: ToDoList()));
    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(find.byType(TextField), findsNWidgets(2));

    await tester.enterText(find.byKey(const Key('timerNameInput')), testString);
    await tester.enterText(
        find.byKey(const Key('timerLifetimeInput')), testTime);
    await tester.pump();
    expect(find.text(testString), findsOneWidget);
    expect(find.text(testTime), findsOneWidget);

    await tester.tap(find.byKey(const Key('OKButton')));
    await tester.pump();
    expect(find.byType(TimerWidget), findsNWidgets(2));
    expect(find.text(testString), findsOneWidget);
  });

  testWidgets('Presence of timerIcon button with a text widget',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ToDoList()));
    expect(find.byKey(Key("counter")), findsNWidgets(1));
    expect(find.byKey(Key("timer")), findsNWidgets(1));
  });
}
