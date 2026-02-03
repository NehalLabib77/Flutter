import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/savings_entry.dart';
import '../models/savings_target.dart';

class SavingsProvider extends ChangeNotifier {
  late Box<SavingsEntry> _savingsBox;
  late Box<SavingsTarget> _targetBox;
  late Box _settingsBox;

  double _totalBalance = 0;
  SavingsTarget? _currentTarget;
  List<SavingsEntry> _savingsHistory = [];
  List<SavingsTarget> _targetHistory = [];

  // Getters
  double get totalBalance => _totalBalance;
  SavingsTarget? get currentTarget => _currentTarget;
  List<SavingsEntry> get savingsHistory => _savingsHistory;
  List<SavingsTarget> get targetHistory => _targetHistory;

  double get remainingAmount => _currentTarget != null
      ? (_currentTarget!.targetAmount - getTotalSavedForCurrentTarget()).clamp(
          0,
          double.infinity,
        )
      : 0;

  int get remainingDays {
    if (_currentTarget == null) return 0;
    return _currentTarget!.targetDate.difference(DateTime.now()).inDays + 1;
  }

  double get progressPercentage {
    if (_currentTarget == null || _currentTarget!.targetAmount == 0) return 0;
    final saved = getTotalSavedForCurrentTarget();
    return (saved / _currentTarget!.targetAmount).clamp(0, 1);
  }

  Color get progressColor {
    if (_currentTarget == null) return Colors.grey;

    if (progressPercentage >= 1) return Colors.green;

    final daysRemaining = remainingDays;
    final daysTotal = _currentTarget!.targetDate
        .difference(_currentTarget!.createdDate)
        .inDays;
    final progressDays = daysTotal - daysRemaining;
    final expectedProgress = progressDays / daysTotal;

    if (progressPercentage >= expectedProgress) return Colors.green;
    if (progressPercentage >= expectedProgress * 0.75) return Colors.orange;
    return Colors.red;
  }

  double get requiredDailySavings =>
      _currentTarget?.getRequiredDailySavings(
        getTotalSavedForCurrentTarget(),
      ) ??
      0;

  // Initialize Hive boxes
  Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters (safe on hot reload)
    if (!Hive.isAdapterRegistered(0))
      Hive.registerAdapter(SavingsEntryAdapter());
    if (!Hive.isAdapterRegistered(1))
      Hive.registerAdapter(SavingsTargetAdapter());

    _savingsBox = await Hive.openBox<SavingsEntry>('savings');
    _targetBox = await Hive.openBox<SavingsTarget>('targets');
    _settingsBox = await Hive.openBox('settings');

    // Ensure default settings exist (e.g., currency)
    if (!_settingsBox.containsKey('currency')) {
      await _settingsBox.put('currency', 'BDT');
    }

    _loadData();
    notifyListeners();
  }

  // Load data from Hive
  void _loadData() {
    _savingsHistory = _savingsBox.values.toList();
    _savingsHistory.sort((a, b) => b.date.compareTo(a.date));

    _targetHistory = _targetBox.values.toList();
    _calculateTotalBalance();
    _loadCurrentTarget();
  }

  void _calculateTotalBalance() {
    _totalBalance = _savingsHistory.fold(0, (sum, entry) => sum + entry.amount);
  }

  void _loadCurrentTarget() {
    if (_targetBox.isEmpty) {
      _currentTarget = null;
      return;
    }

    // Get the last incomplete target
    for (var target in _targetBox.values.toList().reversed) {
      if (!target.isCompleted && !target.isMissed) {
        _currentTarget = target;
        _checkTargetStatus();
        return;
      }
    }

    _currentTarget = null;
  }

  void _checkTargetStatus() {
    if (_currentTarget == null) return;

    final saved = getTotalSavedForCurrentTarget();

    // Check if target is completed
    if (saved >= _currentTarget!.targetAmount) {
      _currentTarget!.isCompleted = true;
      _currentTarget!.save();
      notifyListeners();
      return;
    }

    // Check if target is missed
    if (DateTime.now().isAfter(_currentTarget!.targetDate)) {
      _currentTarget!.isMissed = true;
      _currentTarget!.save();
      notifyListeners();
    }
  }

  double getTotalSavedForCurrentTarget() {
    if (_currentTarget == null) return 0;

    return _savingsHistory
        .where(
          (entry) => entry.date.isAfter(
            _currentTarget!.createdDate.subtract(Duration(days: 1)),
          ),
        )
        .fold(0, (sum, entry) => sum + entry.amount);
  }

  // Add new savings entry
  Future<void> addSavings(double amount, {String? note, DateTime? date}) async {
    _checkTargetStatus();

    final entry = SavingsEntry(
      date: date ?? DateTime.now(),
      amount: amount,
      note: note,
    );

    await _savingsBox.add(entry);
    _loadData();
    _checkTargetStatus();
    notifyListeners();
  }

  // Set or update target
  Future<void> setTarget(double targetAmount, DateTime targetDate) async {
    _checkTargetStatus();

    final target = SavingsTarget(
      targetAmount: targetAmount,
      targetDate: targetDate,
      createdDate: DateTime.now(),
    );

    await _targetBox.add(target);
    _loadData();
    _checkTargetStatus();
    notifyListeners();
  }

  // Update existing target with rollover logic
  Future<void> updateTargetWithRollover(
    double newTargetAmount,
    DateTime newTargetDate,
  ) async {
    if (_currentTarget == null) {
      await setTarget(newTargetAmount, newTargetDate);
      return;
    }

    final saved = getTotalSavedForCurrentTarget();
    final unmetAmount = (_currentTarget!.targetAmount - saved).clamp(
      0,
      double.infinity,
    );

    // Mark current target as missed
    _currentTarget!.isMissed = true;
    await _currentTarget!.save();

    // Calculate new required savings
    final adjustedTargetAmount = newTargetAmount + unmetAmount;

    // Create new target
    final newTarget = SavingsTarget(
      targetAmount: adjustedTargetAmount,
      targetDate: newTargetDate,
      createdDate: DateTime.now(),
    );

    await _targetBox.add(newTarget);
    _loadData();
    _checkTargetStatus();
    notifyListeners();
  }

  // Delete savings entry
  Future<void> deleteSavingsEntry(int index) async {
    await _savingsBox.deleteAt(index);
    _loadData();
    _checkTargetStatus();
    notifyListeners();
  }

  // Get savings for specific date
  List<SavingsEntry> getSavingsForDate(DateTime date) {
    return _savingsHistory
        .where(
          (entry) =>
              entry.date.year == date.year &&
              entry.date.month == date.month &&
              entry.date.day == date.day,
        )
        .toList();
  }

  // Get daily total for specific date
  double getDailyTotal(DateTime date) {
    return getSavingsForDate(date).fold(0, (sum, entry) => sum + entry.amount);
  }

  // Clear all data (for testing)
  Future<void> clearAllData() async {
    await _savingsBox.clear();
    await _targetBox.clear();
    _loadData();
    notifyListeners();
  }
}
