import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

import 'roomies.dart';
import 'task.dart';

class FirebaseController {
  static DatabaseReference get allAreas =>
      FirebaseDatabase.instance.reference().child('areas');

  static DatabaseReference area(String areaName) => allAreas.child(areaName);

  static void newArea(TaskArea taskArea) =>
      area(taskArea.areaName).set(taskArea.toMap());

  static DatabaseReference task(String areaName, String taskId) =>
      area(areaName).child('tasks').child(taskId);

  static void newTask(String areaName, Task newTask) =>
      task(areaName, newTask.id).set(newTask.toMap());

  static void markTaskDone({
    @required String areaName,
    @required String taskId,
    @required Roomie roomie,
  }) =>
      task(areaName, taskId)
          .child('task_logs')
          .child(roomie.name)
          .set(DateTime.now().millisecondsSinceEpoch);
}
