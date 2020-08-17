import 'package:flutter/material.dart';
import 'package:roomies/firebase_controller.dart';
import 'package:roomies/roomies.dart';
import 'package:roomies/task.dart';

class AddAreaScreen extends StatefulWidget {
  @override
  _AddAreaScreenState createState() => _AddAreaScreenState();
}

class _AddAreaScreenState extends State<AddAreaScreen> {
  final _formKey = GlobalKey<FormState>();

  final _areaNameController = TextEditingController();

  final roomiesAssigned = <String>{};

  @override
  void initState() {
    roomiesAssigned.addAll(Roomie.roomies.map((roomie) => roomie.name));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Area'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _areaNameController,
                decoration: const InputDecoration(
                  hintText: 'Area Name',
                ),
                validator: (value) =>
                    value.isEmpty ? 'Please enter some text' : null,
              ),
              ...Roomie.roomies.map(
                (roomie) => CheckboxListTile(
                  title: Text(roomie.name),
                  value: roomiesAssigned.contains(roomie.name),
                  onChanged: (value) => setState(() {
                    if (value) {
                      roomiesAssigned.add(roomie.name);
                    } else {
                      roomiesAssigned.remove(roomie.name);
                    }
                  }),
                ),
              ),
              RaisedButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    // submit.

                    FirebaseController.newArea(TaskArea(
                      tasks: [],
                      areaName: _areaNameController.text,
                      assigned: roomiesAssigned
                          .map((name) => Roomie.forName(name))
                          .toList(),
                    ));

                    Navigator.pop(context);
                  }
                },
                child: Text('Add Area'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
