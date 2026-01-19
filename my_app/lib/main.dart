// main.dart
// Advanced Todo App: Persistent Storage (Hive), Editable Table, Priority, Monthly Summary
// Author: Nehal Labib

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('todoBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo Progress App',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
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
  final box = Hive.box('todoBox');

  String get dateKey => DateFormat('yyyy-MM-dd').format(selectedDate);

  List<Map<String, dynamic>> get tasks {
    return List<Map<String, dynamic>>.from(box.get(dateKey, defaultValue: []));
  }

  void saveTasks(List<Map<String, dynamic>> updated) {
    box.put(dateKey, updated);
    setState(() {});
  }

  void addTask() {
    if (taskController.text.trim().isEmpty) return;
    final updated = tasks;
    updated.add({
      'title': taskController.text,
      'done': false,
      'priority': 'Medium',
    });
    taskController.clear();
    saveTasks(updated);
  }

  double get progress {
    if (tasks.isEmpty) return 0;
    final done = tasks.where((t) => t['done'] == true).length;
    return done / tasks.length;
  }

  Map<String, double> get monthlySummary {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var key in box.keys) {
      final date = DateTime.parse(key);
      final monthKey = DateFormat('yyyy-MM').format(date);
      grouped.putIfAbsent(monthKey, () => []);
      grouped[monthKey]!.addAll(List<Map<String, dynamic>>.from(box.get(key)));
    }

    final Map<String, double> summary = {};
    grouped.forEach((month, tasks) {
      if (tasks.isEmpty) return;
      final done = tasks.where((t) => t['done'] == true).length;
      summary[month] = done / tasks.length;
    });

    return summary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Todo Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MonthlySummaryPage(monthlySummary),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          DateFormat('dd MMM yyyy').format(selectedDate),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: progress),
                    Text('Progress: ${(progress * 100).toStringAsFixed(0)}%'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('taskField'),
                    controller: taskController,
                    decoration: const InputDecoration(
                      labelText: 'New Task',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: addTask, child: const Text('Add')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Done')),
                    DataColumn(label: Text('Task')),
                    DataColumn(label: Text('Priority')),
                    DataColumn(label: Text('Delete')),
                  ],
                  rows: List.generate(tasks.length, (index) {
                    final task = tasks[index];
                    return DataRow(
                      cells: [
                        DataCell(
                          Checkbox(
                            value: task['done'],
                            onChanged: (val) {
                              final updated = tasks;
                              updated[index]['done'] = val;
                              saveTasks(updated);
                            },
                          ),
                        ),
                        DataCell(
                          TextFormField(
                            initialValue: task['title'],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            onFieldSubmitted: (val) {
                              final updated = tasks;
                              updated[index]['title'] = val;
                              saveTasks(updated);
                            },
                          ),
                        ),
                        DataCell(
                          DropdownButton<String>(
                            value: task['priority'],
                            items: ['Low', 'Medium', 'High']
                                .map(
                                  (p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(p),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              final updated = tasks;
                              updated[index]['priority'] = val;
                              saveTasks(updated);
                            },
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              final updated = tasks;
                              updated.removeAt(index);
                              saveTasks(updated);
                            },
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MonthlySummaryPage extends StatelessWidget {
  final Map<String, double> summary;
  const MonthlySummaryPage(this.summary, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Summary')),
      body: ListView(
        children: summary.entries.map((e) {
          return ListTile(
            title: Text(e.key),
            trailing: Text('${(e.value * 100).toStringAsFixed(0)}%'),
          );
        }).toList(),
      ),
    );
  }
}
