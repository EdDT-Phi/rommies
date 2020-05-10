import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

void main() => runApp(MyApp());

final roomies = [
  'Tom',
  'Carmina',
  'Eddie',
];

const roomieImg =
    'https://wanderlustbecomingatraveler.files.wordpress.com/2015/12/roommates.jpg';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(),
      );
}

class MyHomePage extends StatefulWidget {
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
        body: TasksListWidget(task: selectedTask),
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
  final Task task;

  const TasksListWidget({this.task});

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
                    doneBy: 'Eddie',
                  ).toMap());
            },
          );
        },
      );
}

class DoneTask {
  final String taskId;
  final int doneTimestamp;
  final String doneBy;

  DoneTask({
    @required this.doneTimestamp,
    @required this.doneBy,
    @required this.taskId,
  });

  Map<String, String> toMap() => {
        'taskId': '$taskId',
        'doneTimestamp': '$doneTimestamp',
        'doneBy': '$doneBy',
      };
}

class Task {
  final String text;

  // All subtasks are assigned to the same person, if any;
  final List<Task> subtasks;
  final int assignedOffset;

  const Task({
    @required this.text,
    this.assignedOffset = -1,
    this.subtasks = const [],
  });

  String get id => text.toLowerCase().replaceAll(' ', '_');
}

const superTask = const Task(
  text: 'All',
  subtasks: [
    Task(
      text: 'Kitchen',
      assignedOffset: 0,
      subtasks: [
        Task(text: 'Take out trash and recycling'),
        Task(text: 'Empty dishwasher'),
        Task(text: 'Put away unused dishes'),
        Task(text: 'Clear and clean surfaces'),
        Task(text: 'Throw away old food'),
      ],
    ),
    Task(
      text: 'Bathroom',
      assignedOffset: 1,
      subtasks: [
        Task(text: 'Take out trash'),
        Task(text: 'Wipe surfaces'),
        Task(text: 'Wipe mirror'),
        Task(text: 'Wipe faucet'),
        Task(text: 'Vacuum and mop floor'),
        Task(text: 'Clean the toilet'),
      ],
    ),
    Task(
      text: 'Living Area',
      assignedOffset: 2,
      subtasks: [
        Task(text: 'Fold up blankets'),
        Task(text: 'Pick up pillows'),
        Task(text: 'Clean floor'),
      ],
    ),
  ],
);
