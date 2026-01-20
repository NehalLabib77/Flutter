import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'task_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: const MyApp(),
    ),
  );
}

/// ---------------- APP ROOT ----------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Modern Task Manager',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF1E293B),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

/// ---------------- HOME (PAGE VIEW) ----------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentPage == 0 ? 'Weekly Tasks' : 'Monthly Overview',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _currentPage == 0 ? Icons.calendar_view_month : Icons.view_week,
            ),
            onPressed: () {
              _pageController.animateToPage(
                _currentPage == 0 ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (page) {
          setState(() => _currentPage = page);
        },
        children: const [WeeklyTaskPage(), MonthlyCalendarPage()],
      ),
      floatingActionButton: _currentPage == 0 ? const AddTaskButton() : null,
    );
  }
}

/// =================================================
/// PAGE 1 → WEEKLY TASK PAGE
/// =================================================
class WeeklyTaskPage extends StatelessWidget {
  const WeeklyTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Column(
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 16),
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final date = today.add(Duration(days: index));
                    return DayCard(date: date, isWide: isWide);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class DayCard extends StatelessWidget {
  final DateTime date;
  final bool isWide;

  const DayCard({super.key, required this.date, this.isWide = false});

  @override
  Widget build(BuildContext context) {
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final tasks = context.watch<TaskProvider>().getTasksForDate(date);

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: isWide ? 200 : 150),
      child: Card(
        margin: EdgeInsets.only(bottom: isWide ? 16 : 12),
        color: isToday ? Theme.of(context).colorScheme.primaryContainer : null,
        child: Padding(
          padding: EdgeInsets.all(isWide ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isToday
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      DateFormat('EEE, MMM d').format(date),
                      style: TextStyle(
                        color: isToday
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (tasks.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${tasks.where((t) => t.isCompleted).length}/${tasks.length}',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (tasks.isEmpty)
                SizedBox(
                  height: isWide ? 80 : 60,
                  child: const Center(
                    child: Text(
                      'No tasks for this day',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: isWide ? 120 : 100,
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) =>
                        TaskItem(task: tasks[index]),
                  ),
                ),
              const SizedBox(height: 8),
              AddTaskField(date: date),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskItem extends StatelessWidget {
  final dynamic task;

  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: task.isCompleted ? 0.6 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Checkbox(
              value: task.isCompleted,
              onChanged: (_) => context.read<TaskProvider>().toggleTask(task),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                  color: task.isCompleted
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () => context.read<TaskProvider>().deleteTask(task),
              color: Theme.of(context).colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }
}

class AddTaskField extends StatefulWidget {
  final DateTime date;

  const AddTaskField({super.key, required this.date});

  @override
  State<AddTaskField> createState() => _AddTaskFieldState();
}

class _AddTaskFieldState extends State<AddTaskField> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Add a task...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onSubmitted: _addTask,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _addTask(_controller.text),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }

  void _addTask(String title) {
    if (title.trim().isNotEmpty) {
      context.read<TaskProvider>().addTask(title.trim(), widget.date);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class AddTaskButton extends StatelessWidget {
  const AddTaskButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddTaskDialog(context),
      child: const Icon(Icons.add),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddTaskDialog());
  }
}

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _controller = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Task Title',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Date: '),
              TextButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 30),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
                child: Text(DateFormat('MMM d, y').format(_selectedDate)),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              context.read<TaskProvider>().addTask(
                _controller.text.trim(),
                _selectedDate,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// =================================================
/// PAGE 2 → MONTHLY CALENDAR PAGE
/// =================================================
class MonthlyCalendarPage extends StatelessWidget {
  const MonthlyCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final month = DateTime(now.year, now.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstDayOfWeek = DateFormat('E').format(month);
    final startOffset = [
      'Sun',
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
    ].indexOf(firstDayOfWeek.substring(0, 3));

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(isWide ? 32 : 16),
                child: Text(
                  DateFormat('MMMM yyyy').format(month),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Sun', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('Mon', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('Tue', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('Wed', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('Thu', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('Fri', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('Sat', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(isWide ? 32 : 16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: isWide ? 1.2 : 1,
                  ),
                  itemCount: daysInMonth + startOffset,
                  itemBuilder: (context, index) {
                    if (index < startOffset) return const SizedBox.shrink();
                    final day = index - startOffset + 1;
                    final date = DateTime(month.year, month.month, day);
                    final score = context
                        .watch<TaskProvider>()
                        .getCompletionScore(date);
                    return DayCell(day: day, score: score);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class DayCell extends StatelessWidget {
  final int day;
  final int score;

  const DayCell({super.key, required this.day, required this.score});

  String _remark(int score) {
    if (score >= 80) return "Excellent";
    if (score >= 60) return "Good";
    if (score >= 40) return "Fair";
    if (score >= 20) return "Poor";
    return "Very Poor";
  }

  Color _color(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    if (score >= 20) return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final isToday = DateUtils.isSameDay(
      DateTime.now(),
      DateTime(DateTime.now().year, DateTime.now().month, day),
    );

    return Card(
      margin: const EdgeInsets.all(2),
      color: isToday
          ? Theme.of(context).colorScheme.primaryContainer
          : _color(score).withValues(alpha: 0.1),
      child: InkWell(
        onTap: () {
          // Could navigate to daily view
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$day',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isToday
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : null,
                ),
              ),
              if (score > 0) ...[
                const SizedBox(height: 4),
                Text(
                  '$score%',
                  style: TextStyle(
                    fontSize: 12,
                    color: _color(score),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _remark(score),
                  style: TextStyle(fontSize: 10, color: _color(score)),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
