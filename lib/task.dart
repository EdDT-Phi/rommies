
import 'package:flutter/material.dart';
import 'package:rommies/roomies.dart';

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

  const Task({
    @required this.text,
    this.subtasks = const [],
  });

  String get id => text.toLowerCase().replaceAll(' ', '_');
}

const superTask = const Task(
  text: 'All',
  subtasks: [
    Task(
      text: 'Kitchen',
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
      subtasks: [
        Task(text: 'Fold up blankets'),
        Task(text: 'Pick up pillows'),
        Task(text: 'Clean floor'),
      ],
    ),
  ],
);