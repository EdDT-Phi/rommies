import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rommies/roomies.dart';

import 'task.dart';

const roomieImg =
    'https://wanderlustbecomingatraveler.files.wordpress.com/2015/12/roommates.jpg';

class MyHomePage extends StatefulWidget {
  final Roomie roomie;

  const MyHomePage({@required this.roomie});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Task selectedTask = superTask.subtasks[0];

  @override
  Widget build(BuildContext context) => Scaffold(
        drawer: MyDrawer(
          onTaskSelected: (task) => setState(() => selectedTask = task),
        ),
        appBar: AppBar(
          title: Text('Roomie Tasks - ${selectedTask.text}'),
        ),
        body: TasksListWidget(
          task: selectedTask,
          roomie: widget.roomie,
        ),
      );
}

class MyDrawer extends StatelessWidget {
  final void Function(Task) onTaskSelected;

  MyDrawer({this.onTaskSelected});

  @override
  Widget build(BuildContext context) => Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Image.network(roomieImg),
            )
          ]..addAll(superTask.subtasks.map(
              (task) => ListTile(
                title: Text(task.text),
                onTap: () {
                  onTaskSelected(task);
                  Navigator.of(context).pop();
                },
              ),
            )),
        ),
      );
}

final doneStyle =
    TextStyle(color: Colors.black38, decoration: TextDecoration.lineThrough);

class TasksListWidget extends StatelessWidget {
  final Roomie roomie;
  final Task task;

  const TasksListWidget({@required this.task, @required this.roomie});

  @override
  Widget build(BuildContext context) => ListView.builder(
        itemCount: task.subtasks.length,
        itemBuilder: (context, idx) {
          final doneTask = idx % 3 == 0;
          final subTask = task.subtasks[idx];

          return ListTile(
            title: Text(
              subTask.text,
              style: doneTask ? doneStyle : null,
            ),
            onTap: () {
              final now = DateTime.now();
              FirebaseDatabase.instance
                  .reference()
                  .child('tasks')
                  .child('${now.millisecondsSinceEpoch}')
                  .set(DoneTask(
                    taskId: subTask.id,
                    doneTimestamp: now.millisecondsSinceEpoch,
                    doneBy: roomie.name,
                  ).toMap());
            },
          );
        },
      );
}
