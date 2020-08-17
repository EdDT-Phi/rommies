import 'package:flutter/material.dart';

import 'roomies.dart';

class TaskLog {
  final DateTime doneTime;
  final Roomie roomie;

  TaskLog({
    @required this.doneTime,
    @required this.roomie,
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

  Roomie get lastDoneBy {
    if (taskLogs.isEmpty) return null;

    var min = DateTime.now();
    var minLog;
    for (final log in taskLogs) {
      if (log.doneTime.isBefore(min)) {
        min = log.doneTime;
        minLog = log;
      }
    }
    return minLog.roomie;
  }

  Roomie next(List<Roomie> assigned) {
    if (taskLogs.isEmpty) return assigned[0];

    var max = DateTime.now();
    var maxLog;
    for (final roomie in assigned) {
      final log = taskLogs.firstWhere(
        (log) => log.roomie.name == roomie.name,
        orElse: () => null,
      );

      if(log == null) return roomie;

      if (log.doneTime.isAfter(max)) {
        max = log.doneTime;
        maxLog = log;
      }
    }
    return maxLog.roomie;
  }

  Map<String, dynamic> toMap() => {
        'name': taskName,
        'task_logs': Map.fromIterable(
          taskLogs,
          key: (log) => log.roomie.name,
          value: (log) => log.doneTime.millisecondsSinceEpoch,
        ),
      };

  static Task fromMap(dynamic values) => Task(
        taskName: values['name'],
        taskLogs: values['task_logs']
                ?.entries
                ?.map<TaskLog>((keyValue) => TaskLog(
                      roomie: Roomie.forName(keyValue.key),
                      doneTime:
                          DateTime.fromMillisecondsSinceEpoch(keyValue.value),
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
