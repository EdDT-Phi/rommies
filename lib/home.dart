import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'roomies.dart';
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
  Task selectedTask;

  @override
  void initState() {
    selectedTask = superTask.subtasks[widget.roomie.taskIdx];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final roomieAssignedToTask = Roomie.roomies.firstWhere(
        (roomie) => roomie.taskIdx == superTask.subtasks.indexOf(selectedTask));

    return Scaffold(
      drawer: MyDrawer(
        onTaskSelected: (task) => setState(() => selectedTask = task),
      ),
      appBar: AppBar(
        title: Text('${selectedTask.text} - ${roomieAssignedToTask.name}'),
      ),
      body: TasksListWidget(
        task: selectedTask,
        roomie: widget.roomie,
      ),
    );
  }
}

class MyDrawer extends StatelessWidget {
  final void Function(Task) onTaskSelected;

  MyDrawer({this.onTaskSelected});

  @override
  Widget build(BuildContext context) => Drawer(
        child: ListView.builder(
          itemCount: Roomie.roomies.length + 1,
          itemBuilder: (context, idx) {
            if (idx == 0) {
              return DrawerHeader(
                child: Image.network(roomieImg),
              );
            }

            final task = superTask.subtasks[idx - 1];
            final roomieIdx = (Roomie.weekNum + idx - 1) % Roomie.roomies.length;

            return ListTile(
              title: Text('${task.text} - ${Roomie.roomies[roomieIdx].name}'),
              onTap: () {
                onTaskSelected(task);
                Navigator.of(context).pop();
              },
            );
          },
        ),
      );
}

final doneStyle =
    TextStyle(color: Colors.black38, decoration: TextDecoration.lineThrough);

class TasksListWidget extends StatefulWidget {
  final Roomie roomie;
  final Task task;

  const TasksListWidget({@required this.task, @required this.roomie});

  @override
  _TasksListWidgetState createState() => _TasksListWidgetState();
}

class _TasksListWidgetState extends State<TasksListWidget> {
  Future<List<DoneTask>> doneTaskLogs;

  @override
  void initState() {
    updateData();

    super.initState();
  }

  void updateData() async {
    doneTaskLogs = getDataFromDb();
  }

  Future<List<DoneTask>> getDataFromDb() async =>
      logsToData(await createQuery().once());

  List<DoneTask> logsToData(DataSnapshot snapshot) => snapshot.value.values
      .map<DoneTask>((values) => DoneTask.fromMap(values))
      .toList();

  Query createQuery() => FirebaseDatabase.instance
      .reference()
      .child('tasks')
      .startAt(null, key: startOfWeekKey);

  static String get startOfWeekKey {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    // If Monday, subtract 6 days to get to last Tuesday.
    // Tuesday is start of week.
    final startOfWeek = startOfToday.weekday == 1
        ? startOfToday.subtract(Duration(days: 6))
        : startOfToday.subtract(Duration(days: today.weekday - 2));

    return '${startOfWeek.millisecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<DoneTask>>(
        future: doneTaskLogs,
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text(snapshot.error.toString());
          if (!snapshot.hasData) return CircularProgressIndicator();

          final doneTasks = snapshot.data.map((task) => task.taskId).toSet();

          return ListView.builder(
            itemCount: widget.task.subtasks.length,
            itemBuilder: (context, idx) {
              final subTask = widget.task.subtasks[idx];
              final doneTask = doneTasks.contains(subTask.id);

              return ListTile(
                enabled: !doneTask,
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
                        doneBy: widget.roomie.name,
                      ).toMap());
                },
              );
            },
          );
        },
      );
}
