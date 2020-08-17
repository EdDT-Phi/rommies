import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:roomies/add_area.dart';
import 'package:roomies/add_task.dart';
import 'package:roomies/firebase_controller.dart';

import 'roomies.dart';
import 'task.dart';

const roomieImg =
    'https://wanderlustbecomingatraveler.files.wordpress.com/2015/12/roommates.jpg';

class MyHomePage extends StatelessWidget {
  final Roomie roomie;

  const MyHomePage({@required this.roomie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Roomies'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => AddAreaScreen())),
      ),
      body: TasksListWidget(
        roomie: roomie,
      ),
    );
  }
}

class TasksListWidget extends StatefulWidget {
  final Roomie roomie;

  const TasksListWidget({@required this.roomie});

  @override
  _TasksListWidgetState createState() => _TasksListWidgetState();
}

class _TasksListWidgetState extends State<TasksListWidget> {
  Future<AllTasks> allTasksFuture;
  Stream<AllTasks> allTasksStream;

  @override
  void initState() {
    updateData();
    allTasksStream = createStream();

    super.initState();
  }

  void updateData() async {
    allTasksFuture = getDataFromDb();
  }

  Future<AllTasks> getDataFromDb() async =>
      logsToData(await createQuery().once());

  AllTasks logsToData(DataSnapshot snapshot) =>
      AllTasks.fromMap(snapshot.value ?? {});

  DatabaseReference createQuery() => FirebaseController.allAreas;

  Stream<AllTasks> createStream() => createQuery()
      .onValue
      .map<AllTasks>((event) => logsToData(event.snapshot));

  @override
  Widget build(BuildContext context) => FutureBuilder<AllTasks>(
        future: allTasksFuture,
        builder: (context, futureSnapshot) {
          if (futureSnapshot.hasError)
            return Text(futureSnapshot.error.toString());
          if (!futureSnapshot.hasData) return CircularProgressIndicator();

          return StreamBuilder<AllTasks>(
              initialData: futureSnapshot.data,
              stream: allTasksStream,
              builder: (context, streamSnapshot) {

                if (streamSnapshot.hasError)
                  return Text(streamSnapshot.error.toString());
                if (!streamSnapshot.hasData) return CircularProgressIndicator();

                return ListView.builder(
                  itemBuilder: (context, idx) {
                    final area = streamSnapshot.data.taskAreas[idx];
                    return ExpansionTile(
                      title: Text(area.areaName),
                      children: area.tasks
                          .map<Widget>((task) => ListTile(
                                title: Text(task.taskName),
                              ))
                          .toList()
                            ..add(ListTile(
                              title: RaisedButton.icon(
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddTaskScreen(
                                        areaName: area.areaName,
                                      ),
                                    )),
                                icon: Icon(Icons.add),
                                label: Text('Add Task'),
                              ),
                            )),
                    );
                  },
                  itemCount: streamSnapshot.data.taskAreas.length,
                );
              });
        },
      );
}
