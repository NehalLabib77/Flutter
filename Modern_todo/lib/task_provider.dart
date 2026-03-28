import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'task.dart';

class TaskProvider extends ChangeNotifier {
  late Box<Task> _taskBox;
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  TaskProvider() {
    _initHive();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    _taskBox = await Hive.openBox<Task>('tasks');
    _loadTasks();
  }

  void _loadTasks() {
    _tasks = _taskBox.values.toList();
    notifyListeners();
  }

  List<Task> getTasksForDate(DateTime date) {
    return _tasks
        .where(
          (task) =>
              task.date.year == date.year &&
              task.date.month == date.month &&
              task.date.day == date.day,
        )
        .toList();
  }

  Future<void> addTask(String title, DateTime date) async {
    final task = Task(title: title, date: date);
    await _taskBox.add(task);
    _loadTasks();
  }

  Future<void> toggleTask(Task task) async {
    task.isCompleted = !task.isCompleted;
    await task.save();
    _loadTasks();
  }

  Future<void> deleteTask(Task task) async {
    await task.delete();
    _loadTasks();
  }

  int getCompletionScore(DateTime date) {
    final tasksForDate = getTasksForDate(date);
    if (tasksForDate.isEmpty) return 0;
    final completed = tasksForDate.where((task) => task.isCompleted).length;
    return ((completed / tasksForDate.length) * 100).round();
  }
}
