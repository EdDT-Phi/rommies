import 'package:flutter/material.dart';
import 'package:roomies/firebase_controller.dart';
import 'package:roomies/task.dart';

class AddTaskScreen extends StatefulWidget {
  final String areaName;

  const AddTaskScreen({Key key, @required this.areaName}) : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  final _taskNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _taskNameController,
                decoration: const InputDecoration(
                  hintText: 'Task Name',
                ),
                validator: (value) =>
                    value.isEmpty ? 'Please enter some text' : null,
              ),
              RaisedButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    // submit.

                    FirebaseController.newTask(
                        widget.areaName,
                        Task(
                          taskName: _taskNameController.text,
                          taskLogs: [],
                        ));

                    Navigator.pop(context);
                  }
                },
                child: Text('Add Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
