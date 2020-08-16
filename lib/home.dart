import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'roomies.dart';
import 'task.dart';
import 'dates.dart';

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
    final selectedTaskIdx = superTask.subtasks.indexOf(selectedTask);
    final roomieAssignedToTask = Roomie.roomies
        .firstWhere((roomie) => roomie.taskIdx == selectedTaskIdx);

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
            final roomieAssignedToTask = Roomie.roomies
                .firstWhere((roomie) => roomie.taskIdx == idx - 1);

            return ListTile(
              title: Text('${task.text} - ${roomieAssignedToTask.name}'),
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
  Future<List<DoneTask>> doneTaskFuture;
  Stream<List<DoneTask>> doneTaskStream;

  @override
  void initState() {
    updateData();
    doneTaskStream = createStream();

    super.initState();
  }

  void updateData() async {
    doneTaskFuture = getDataFromDb();
  }

  Future<List<DoneTask>> getDataFromDb() async =>
      logsToData(await createQuery().once());

  List<DoneTask> logsToData(DataSnapshot snapshot) => (snapshot.value ?? {})
      .values
      .map<DoneTask>((values) => DoneTask.fromMap(values))
      .toList();

  DatabaseReference createQuery() => FirebaseDatabase.instance
      .reference()
      .child('tasks')
      .child('${RoomieDates.weekNum}');

  Stream<List<DoneTask>> createStream() => createQuery()
      .onValue
      .map<List<DoneTask>>((event) => logsToData(event.snapshot));

  @override
  Widget build(BuildContext context) => FutureBuilder<List<DoneTask>>(
        future: doneTaskFuture,
        builder: (context, futureSnapshot) {
          if (futureSnapshot.hasError)
            return Text(futureSnapshot.error.toString());
          if (!futureSnapshot.hasData) return CircularProgressIndicator();

          return StreamBuilder<List<DoneTask>>(
              initialData: futureSnapshot.data,
              stream: doneTaskStream,
              builder: (context, streamSnapshot) {
                final doneTasks =
                    streamSnapshot.data.map((task) => task.taskId).toSet();

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
                        createQuery()
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
              });
        },
      );
}
