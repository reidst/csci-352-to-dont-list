// Started with https://docs.flutter.dev/development/ui/widgets-intro
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:to_dont_list/countdown_timer.dart';

class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  State createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  // Dialog with text from https://www.appsdeveloperblog.com/alert-dialog-with-a-text-field-in-flutter/
  final TextEditingController _nameInputController = TextEditingController();
  final TextEditingController _timeInputController = TextEditingController();
  final ButtonStyle yesStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20), primary: Colors.green);
  final ButtonStyle noStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20), primary: Colors.red);

  Future<void> _displayTextInputDialog(BuildContext context) async {
    timerNameInput = '';
    timerLifetimeInput = 10;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Timer To Add'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  key: const Key('timerNameInput'),
                  onChanged: (value) {
                    setState(() { timerNameInput = value; });
                  },
                  controller: _nameInputController,
                  decoration: const InputDecoration(hintText: 'timer name'),
                ),
                TextField(
                  key: const Key('timerLifetimeInput'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    setState(() {
                      timerLifetimeInput = int.tryParse(value) ?? timerLifetimeInput;
                    });
                  },
                  controller: _timeInputController,
                  decoration: const InputDecoration(hintText: 'time length'),
                ),
              ],
            ),
            actions: <Widget>[

              // https://stackoverflow.com/questions/52468987/how-to-turn-disabled-button-into-enabled-button-depending-on-conditions
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _nameInputController,
                builder: (context, value, child) {
                  return ElevatedButton(
                    key: const Key("OKButton"),
                    style: yesStyle,
                    onPressed: value.text.isNotEmpty
                        ? () {
                            setState(() {
                              _handleNewItem(timerNameInput, timerLifetimeInput);
                              Navigator.pop(context);
                            });
                          }
                        : null,
                    child: const Text('OK'),
                  );
                },
              ),
              ElevatedButton(
                key: const Key("CancelButton"),
                style: noStyle,
                child: const Text('Cancel'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  String timerNameInput = "";
  int timerLifetimeInput = 0;

  late List<TimerWidget> items = [TimerWidget(
    description: "Create your own timers!",
    lifetime: 10,
    onTimerFinish: _handleDeleteItem,
  )];

  void _handleDeleteItem() {
    setState(() {
      items.removeWhere((timer) => timer.isFinished);
    });
  }

  void _handleNewItem(String itemText, int itemLifetime) {
    setState(() {
      items.add(TimerWidget(
        description: itemText, 
        lifetime: itemLifetime, 
        onTimerFinish: _handleDeleteItem
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.brown[100],
        appBar: AppBar(
          title: const Center(child: Text('To Time List')),
        ),
        // ListView.builder solution from https://www.geeksforgeeks.org/listview-builder-in-flutter/
        body: ListView.builder(
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            return items[index];
          },
        ),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              _displayTextInputDialog(context);
            }));
  }
}

void main() {
  runApp(MaterialApp(
    title: 'To Time List',
    theme: ThemeData(
      primarySwatch: Colors.brown,
    ),
    home: const ToDoList(),
  ));
}
