import 'package:flutter/material.dart';

void main() => runApp(MyApp());

const roomies =
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
  TaskListCategory selectedCategory = TaskListCategory.kitchen;

  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: MyDrawer(
      onCategorySelected: (option) =>
          setState(() => selectedCategory = option),
    ),
    appBar: AppBar(
      title: Text('Roomie Tasks - ${selectedCategory.title}'),
    ),
    body: TasksListWidget(taskCategory: selectedCategory),
  );
}

class MyDrawer extends StatelessWidget {
  final void Function(TaskListCategory) onCategorySelected;

  MyDrawer({this.onCategorySelected});

  @override
  Widget build(BuildContext context) => Drawer(
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          child: Image.network(roomies),
        )
      ]..addAll(TaskListCategory.allCategories.map(
            (category) => ListTile(
          title: Text(category.title),
          onTap: () => onCategorySelected(category),
        ),
      )),
    ),
  );
}

class TasksListWidget extends StatefulWidget {
  final TaskListCategory taskCategory;

  const TasksListWidget({this.taskCategory});

  @override
  _TasksListWidgetState createState() => _TasksListWidgetState();
}

final doneStyle =
TextStyle(color: Colors.black38, decoration: TextDecoration.lineThrough);

class _TasksListWidgetState extends State<TasksListWidget> {
  Future<TaskList> tasks;

  @override
  void initState() {
    tasks = TaskListProvider.tasksForCategory(widget.taskCategory.id);

    super.initState();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<TaskList>(
    future: tasks,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Text(snapshot.error);
      }

      if (!snapshot.hasData) {
        return CircularProgressIndicator();
      }

      return ListView.builder(
        itemBuilder: (context, idx) {
          if (idx >= snapshot.data.tasks.length) return null;
          final task = snapshot.data.tasks[idx];
          return ListTile(
            onTap: () {},
            title: Text(
              task.text,
              style: task.done ? doneStyle : null,
            ),
          );
        },
      );
    },
  );
}

class TaskListCategory {
  final String id;
  final String title;

  static const kitchen = TaskListCategory(
    id: 'kitchen',
    title: 'Kitchen',
  );

  static const bathroom = TaskListCategory(
    id: 'bathroom',
    title: 'Bathroom',
  );

  static const living_area = TaskListCategory(
    id: 'living_area',
    title: 'Living Area',
  );

  static const allCategories = [kitchen, bathroom, living_area];

  const TaskListCategory({this.id, this.title});
}

class TaskList {
  final List<Task> tasks;
  final TaskListCategory category;

  TaskList({this.tasks, this.category});
}

class Task {
  final bool done;
  final String text;
  final String taskId;
  final String description;

  Task({this.taskId, this.description, this.done, this.text});
}

class TaskListProvider {
  static Future<TaskList> tasksForCategory(String taskCategory) async =>
      TaskList(
        tasks: [
          Task(done: false, text: "Clean mirror"),
          Task(done: true, text: "Clean toilet"),
          Task(done: false, text: "Clean floor"),
          Task(done: false, text: "Clean tub"),
          Task(done: false, text: "Clean $taskCategory"),
        ],
      );
}
