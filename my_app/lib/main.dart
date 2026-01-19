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
    final raw = box.get(dateKey, defaultValue: <Map<String, dynamic>>[]);
    return List<Map<String, dynamic>>.from(
      raw.map((e) => Map<String, dynamic>.from(e)),
    );
  }

  Future<void> saveTasks(List<Map<String, dynamic>> updated) async {
    await box.put(dateKey, updated);
    // No setState needed with ValueListenableBuilder
  }

  Future<void> addTask() async {
    if (taskController.text.trim().isEmpty) return;

    final updated = tasks;
    updated.add({
      'title': taskController.text,
      'done': false,
      'priority': 'Medium',
    });

    taskController.clear();
    await saveTasks(updated);
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
      final raw = box.get(key, defaultValue: <Map<String, dynamic>>[]);
      grouped[monthKey]!.addAll(
        List<Map<String, dynamic>>.from(
          raw.map((e) => Map<String, dynamic>.from(e)),
        ),
      );
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
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box box, _) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// HEADER CARD
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
                        const SizedBox(height: 4),
                        Text(
                          'Progress: ${(progress * 100).toStringAsFixed(0)}%',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// ADD TASK ROW
                Row(
                  children: [
                    Expanded(
                      child: TextField(
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

                /// TASK TABLE
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
                                onChanged: (val) async {
                                  final updated = tasks;
                                  updated[index]['done'] = val;
                                  await saveTasks(updated);
                                },
                              ),
                            ),
                            DataCell(
                              TextFormField(
                                initialValue: task['title'],
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                                onFieldSubmitted: (val) async {
                                  final updated = tasks;
                                  updated[index]['title'] = val;
                                  await saveTasks(updated);
                                },
                              ),
                            ),
                            DataCell(
                              DropdownButton<String>(
                                value: task['priority'],
                                underline: const SizedBox(),
                                items: ['Low', 'Medium', 'High']
                                    .map(
                                      (p) => DropdownMenuItem(
                                        value: p,
                                        child: Text(p),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) async {
                                  final updated = tasks;
                                  updated[index]['priority'] = val;
                                  await saveTasks(updated);
                                },
                              ),
                            ),
                            DataCell(
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final updated = tasks;
                                  updated.removeAt(index);
                                  await saveTasks(updated);
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
          );
        },
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
