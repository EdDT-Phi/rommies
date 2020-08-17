import 'package:flutter/material.dart';

import 'roomies.dart';

class TaskLog {
  final int doneTimestamp;
  final String doneBy; // Name

  TaskLog({
    @required this.doneTimestamp,
    @required this.doneBy,
  });
}

class Task {
  final String taskName;

  final List<TaskLog> taskLogs;

  const Task({
    @required this.taskName,
    @required this.taskLogs,
  });

  String get id => taskName.toLowerCase().replaceAll(' ', '_');

  Map<String, dynamic> toMap() => {
        'name': taskName,
        'task_logs': Map.fromIterable(
          taskLogs,
          key: (log) => log.name,
          value: (log) => log.timestamp,
        ),
      };

  static Task fromMap(dynamic values) => Task(
        taskName: values['name'],
        taskLogs: values['task_logs']
                ?.entries
                ?.map((keyValue) => TaskLog(
                      doneBy: keyValue.key,
                      doneTimestamp: keyValue.value,
                    ))
                ?.toList() ??
            [],
      );
}

class TaskArea {
  final String areaName;

  final List<Roomie> assigned;
  final List<Task> tasks;

  TaskArea({
    @required this.areaName,
    @required this.tasks,
    @required this.assigned,
  });

  Map<String, dynamic> toMap() => {
        'assigned': Map.fromIterable(
          assigned,
          key: (roomie) => roomie.name,
          value: (roomie) => roomie.name,
        ),
        'tasks': Map.fromIterable(
          tasks,
          key: (task) => task.taskName,
          value: (task) => task.toMap(),
        ),
      };

  static TaskArea fromMap(String areaName, dynamic values) => TaskArea(
        areaName: areaName,
        assigned: values['assigned']
            .entries
            .map<Roomie>((keyValue) => Roomie.forName(keyValue.key))
            .toList(),
        tasks: values['tasks']
                ?.values
                ?.map<Task>((value) => Task.fromMap(value))
                ?.toList() ??
            [],
      );
}

class AllTasks {
  final List<TaskArea> taskAreas;

  AllTasks({@required this.taskAreas});

  static AllTasks fromMap(dynamic values) => AllTasks(
        taskAreas: values.entries
            .map<TaskArea>(
                (keyValue) => TaskArea.fromMap(keyValue.key, keyValue.value))
            .toList(),
      );
}
