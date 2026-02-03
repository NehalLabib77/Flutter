# Savings Tracker App - Code Examples & Usage

## 🎯 Usage Examples

### Example 1: Basic Flow - Setting a Goal

```dart
// In TargetSetupScreen
final provider = Provider.of<SavingsProvider>(context, listen: false);

// User enters $500 target, 30 days from now
final targetAmount = 500.0;
final targetDate = DateTime.now().add(Duration(days: 30));

// Set the target
provider.setTarget(targetAmount, targetDate);

// App automatically calculates:
// - Required daily savings: $500 / 30 = $16.67/day
// - Progress color: Green (on track)
```

### Example 2: Adding Daily Savings

```dart
// In AddSavingsScreen
final provider = Provider.of<SavingsProvider>(context, listen: false);

// User adds $25 today
final amount = 25.0;
final note = "Freelance work";
final date = DateTime.now();

provider.addSavings(amount, note: note, date: date);

// Dashboard updates:
// - Total Balance: $25
// - Progress: 5% ($25/$500)
// - Remaining: $475
// - Required Daily: $16.67
```

### Example 3: Handling Missed Targets

```dart
// Scenario: Target was $200, deadline was 5 days ago
// User saved $120

// Current state
final target = provider.currentTarget; // targetAmount = 200
final saved = provider.getTotalSavedForCurrentTarget(); // 120
final unmet = 200 - 120; // 80

// User wants to set new target for $250
provider.updateTargetWithRollover(250, newDate);

// New target calculation:
// newTarget = 250 + 80 = $330
// Balance remains: $120
// Unmet amount: $330 - $120 = $210
```

---

## 📊 Accessing Provider Data in Widgets

### Consumer Pattern (Recommended)

```dart
Consumer<SavingsProvider>(
  builder: (context, provider, child) {
    return Column(
      children: [
        // Total Balance
        Text('Balance: \$${provider.totalBalance.toStringAsFixed(2)}'),
        
        // Progress
        Text('Progress: ${(provider.progressPercentage * 100).toStringAsFixed(1)}%'),
        
        // Status
        if (provider.currentTarget != null)
          Text('Days Left: ${provider.remainingDays}')
        else
          Text('No active target'),
      ],
    );
  },
)
```

### With Listen: False (For Actions)

```dart
final provider = Provider.of<SavingsProvider>(context, listen: false);
provider.addSavings(100);
```

---

## 🔄 Business Logic Examples

### Calculating Color Code

```dart
// From SavingsProvider
Color get progressColor {
  if (progressPercentage >= 1) return Colors.green;  // Completed
  
  // Calculate expected progress
  final daysTotal = currentTarget.targetDate
      .difference(currentTarget.createdDate).inDays;
  final daysRemaining = remainingDays;
  final progressDays = daysTotal - daysRemaining;
  final expectedProgress = progressDays / daysTotal;
  
  // Color based on pace
  if (progressPercentage >= expectedProgress) 
    return Colors.green;  // On track
  if (progressPercentage >= expectedProgress * 0.75)
    return Colors.orange;  // Behind but salvageable
  return Colors.red;  // Significantly behind
}
```

### Updating Dashboard in Real-Time

```dart
// When user adds savings, this triggers automatically:
void _checkTargetStatus() {
  if (_currentTarget == null) return;
  
  final saved = getTotalSavedForCurrentTarget();
  
  // Check completion
  if (saved >= _currentTarget!.targetAmount) {
    _currentTarget!.isCompleted = true;
    _currentTarget!.save();  // Persist to Hive
    notifyListeners();  // Rebuild all Consumers
    return;
  }
  
  // Check if missed
  if (DateTime.now().isAfter(_currentTarget!.targetDate)) {
    _currentTarget!.isMissed = true;
    _currentTarget!.save();
    notifyListeners();
  }
}
```

---

## 🗄️ Database Operations

### Adding a Savings Entry

```dart
Future<void> addSavings(double amount, {String? note, DateTime? date}) async {
  _checkTargetStatus();  // Update before saving
  
  final entry = SavingsEntry(
    date: date ?? DateTime.now(),
    amount: amount,
    note: note,
  );
  
  await _savingsBox.add(entry);  // Save to Hive
  _loadData();  // Reload data
  _checkTargetStatus();  // Check status again
  notifyListeners();  // Notify UI
}
```

### Loading Data from Hive

```dart
void _loadData() {
  // Load all savings
  _savingsHistory = _savingsBox.values.toList();
  _savingsHistory.sort((a, b) => b.date.compareTo(a.date));  // Newest first
  
  // Load all targets
  _targetHistory = _targetBox.values.toList();
  
  // Calculate totals
  _calculateTotalBalance();
  _loadCurrentTarget();
}

void _calculateTotalBalance() {
  _totalBalance = _savingsHistory.fold(0, (sum, entry) => sum + entry.amount);
}
```

### Deleting an Entry

```dart
Future<void> deleteSavingsEntry(int index) async {
  await _savingsBox.deleteAt(index);  // Remove from Hive
  _loadData();  // Reload everything
  _checkTargetStatus();  // Update target status
  notifyListeners();  // Rebuild UI
}
```

---

## 🎨 UI Examples

### Building the Progress Card

```dart
Card(
  elevation: 2,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        // Header with progress %
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text(
              '${(provider.progressPercentage * 100).toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: provider.progressColor),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: provider.progressPercentage,
            minHeight: 12,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(provider.progressColor),
          ),
        ),
        const SizedBox(height: 12),
        
        // Saved vs Remaining
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text('Saved', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text('\$${provider.getTotalSavedForCurrentTarget().toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Column(
              children: [
                Text('Remaining', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text('\$${provider.remainingAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ),
)
```

### Building the History List

```dart
// Group savings by date
final groupedByDate = <String, List<dynamic>>{};
for (var entry in provider.savingsHistory) {
  final dateKey = DateFormat('MMM dd, yyyy').format(entry.date);
  groupedByDate.putIfAbsent(dateKey, () => []);
  groupedByDate[dateKey]!.add(entry);
}

// Build list
ListView.builder(
  itemCount: groupedByDate.length,
  itemBuilder: (context, index) {
    final dateKey = groupedByDate.keys.toList()[index];
    final entries = groupedByDate[dateKey]!;
    final dailyTotal = entries.fold<double>(0, (sum, e) => sum + e.amount);
    
    return Card(
      child: Column(
        children: [
          Container(
            color: Colors.blue[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateKey),
                Text('+\$${dailyTotal.toStringAsFixed(2)}', style: TextStyle(color: Colors.green)),
              ],
            ),
          ),
          // Individual entries
          for (var entry in entries)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text('\$${entry.amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold)),
                      if (entry.note != null) Text(entry.note!),
                    ],
                  ),
                  // Delete button
                  PopupMenuButton(
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        onTap: () => provider.deleteSavingsEntry(provider.savingsHistory.indexOf(entry)),
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  },
)
```

---

## ⚙️ Configuration & Customization

### Changing Theme Colors

```dart
// In main.dart
theme: ThemeData(
  primarySwatch: Colors.blue,
  useMaterial3: true,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.blueAccent,  // Change app bar color
  ),
)
```

### Adjusting Progress Color Thresholds

```dart
// In savings_provider.dart
Color get progressColor {
  if (progressPercentage >= 1) return Colors.green;
  if (progressPercentage >= 0.85) return Colors.lightGreen;  // New threshold
  if (progressPercentage >= expectedProgress) return Colors.green;
  if (progressPercentage >= expectedProgress * 0.70) return Colors.orange;  // Adjusted
  return Colors.red;
}
```

### Formatting Currency

```dart
// In any screen
Text('\$${amount.toStringAsFixed(2)}')

// Or use intl package
import 'package:intl/intl.dart';

final formatter = NumberFormat.currency(symbol: '\$');
Text(formatter.format(amount))
```

---

## 🧪 Testing Scenarios

### Test 1: Happy Path
```
1. Set target: $100, 30 days
2. Add $25, $25, $25, $25 → Total $100
3. Check: Completed message shows
4. New target button visible
```

### Test 2: Rollover Logic
```
1. Set target: $100, yesterday
2. Add $60
3. Check: "Target Missed" shown
4. Update target: $200
5. Check: Required = $200 + $40 = $240
```

### Test 3: Progress Tracking
```
1. Set target: $50, 10 days
2. Add $10 daily for 3 days → $30
3. Day 4: Check color = Orange (behind pace)
4. Add $20 → $50
5. Check color = Green (completed)
```

---

## 📝 Code Style Guidelines

```dart
// Use final for data that won't change
final target = provider.currentTarget;

// Use late for initialization after constructor
late Box<SavingsEntry> _savingsBox;

// Use descriptive variable names
final unmetAmount = targetAmount - currentSavings;

// Use null coalescing for defaults
final dateKey = entry.date.toString() ?? DateTime.now().toString();

// Use try-catch for async operations
try {
  await _savingsBox.add(entry);
} catch (e) {
  print('Error adding entry: $e');
}
```

---

## 🚀 Performance Tips

1. **Use Consumer with Child Parameter** to avoid rebuilding static widgets
2. **Sort data once** instead of sorting in build
3. **Cache calculations** in getters
4. **Use const constructors** for unchanging widgets
5. **Lazy load** in ListViews with `lazy: true`

---

## 📞 Debugging Tips

```dart
// Print state changes
void _loadData() {
  _savingsHistory = _savingsBox.values.toList();
  print('Loaded ${_savingsHistory.length} savings entries');
  print('Total balance: \$$_totalBalance');
}

// Check target status
print('Current target: \$${_currentTarget?.targetAmount}');
print('Target date: ${_currentTarget?.targetDate}');
print('Is missed: ${_currentTarget?.isMissed}');
```

---

**That covers the main usage patterns and examples!** 🎉
