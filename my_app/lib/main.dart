// main.dart
// Simple To-Do App with Date, Progress, and History
// Author: Nehal Labib (customizable)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo Progress App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TodoHomePage(),
    );
  }
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  DateTime selectedDate = DateTime.now();
  final TextEditingController taskController = TextEditingController();

  // date -> list of tasks
  final Map<String, List<TodoItem>> tasksByDate = {};

  String get dateKey => DateFormat('yyyy-MM-dd').format(selectedDate);

  void addTask() {
    if (taskController.text.trim().isEmpty) return;

    tasksByDate.putIfAbsent(dateKey, () => []);
    tasksByDate[dateKey]!.add(TodoItem(title: taskController.text));

    taskController.clear();
    setState(() {});
  }

  double get progress {
    final tasks = tasksByDate[dateKey] ?? [];
    if (tasks.isEmpty) return 0;
    final done = tasks.where((t) => t.isDone).length;
    return done / tasks.length;
  }

  Map<String, double> get historyProgress {
    final Map<String, double> history = {};

    tasksByDate.forEach((date, tasks) {
      if (tasks.isEmpty) return;
      final done = tasks.where((t) => t.isDone).length;
      history[date] = done / tasks.length;
    });

    return history;
  }

  @override
  Widget build(BuildContext context) {
    final tasks = tasksByDate[dateKey] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Progress App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HistoryPage(historyProgress)),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Picker
            Row(
              children: [
                Text(
                  DateFormat('dd MMM yyyy').format(selectedDate),
                  style: const TextStyle(fontSize: 18),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress Bar
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 6),
            Text('Progress: ${(progress * 100).toStringAsFixed(0)}%'),

            const Divider(height: 24),

            // Task Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('taskField'),
                    controller: taskController,
                    decoration: const InputDecoration(
                      hintText: 'Add a task...',
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.add), onPressed: addTask),
              ],
            ),

            const SizedBox(height: 12),

            // Task List
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (_, index) {
                  final task = tasks[index];
                  return CheckboxListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    value: task.isDone,
                    onChanged: (val) {
                      setState(() => task.isDone = val ?? false);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TodoItem {
  final String title;
  bool isDone;

  TodoItem({required this.title, this.isDone = false});
}

class HistoryPage extends StatelessWidget {
  final Map<String, double> history;

  const HistoryPage(this.history, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: ListView(
        children: history.entries.map((entry) {
          return ListTile(
            title: Text(entry.key),
            trailing: Text(
              '${(entry.value * 100).toStringAsFixed(0)}% completed',
            ),
          );
        }).toList(),
      ),
    );
  }
}
