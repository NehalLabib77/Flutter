import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];
  int _nextTaskId = 1;

  List<Task> get tasks => _tasks;

  void addTask(String title) {
    final int taskId = _nextTaskId++;
    _tasks.add(Task(id: taskId, title: title, color: _colorForTaskId(taskId)));
    notifyListeners();
  }

  void toggleTask(int index) {
    _tasks[index].toggle();
    notifyListeners();
  }

  void deleteTask(int index) {
    _tasks.removeAt(index);
    notifyListeners();
  }

  Color _colorForTaskId(int id) {
    // Golden-angle hue steps keep neighboring task colors visually distinct.
    final double hue = (id * 137.508) % 360;
    return HSLColor.fromAHSL(1, hue, 0.70, 0.55).toColor();
  }
}
