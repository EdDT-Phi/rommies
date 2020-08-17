import 'package:firebase_database/firebase_database.dart';

import 'task.dart';

class FirebaseController {
  static DatabaseReference get allAreas =>
      FirebaseDatabase.instance.reference().child('areas');

  static DatabaseReference area(String areaName) => allAreas.child(areaName);

  static void newArea(TaskArea taskArea) =>
      area(taskArea.areaName).set(taskArea.toMap());

  static DatabaseReference task(String areaName, String taskName) =>
      area(areaName).child('tasks').child(taskName);

  static void newTask(String areaName, Task newTask) =>
      task(areaName, newTask.taskName).set(newTask.toMap());
}
