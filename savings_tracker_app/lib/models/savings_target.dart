import 'package:hive_flutter/hive_flutter.dart';

part 'savings_target.g.dart';

@HiveType(typeId: 1)
class SavingsTarget extends HiveObject {
  @HiveField(0)
  late double targetAmount;

  @HiveField(1)
  late DateTime targetDate;

  @HiveField(2)
  late DateTime createdDate;

  @HiveField(3)
  late bool isCompleted;

  @HiveField(4)
  late bool isMissed;

  SavingsTarget({
    required this.targetAmount,
    required this.targetDate,
    required this.createdDate,
    this.isCompleted = false,
    this.isMissed = false,
  });

  double getRequiredDailySavings(double currentSavings) {
    final remaining = targetAmount - currentSavings;
    final daysRemaining = targetDate.difference(DateTime.now()).inDays + 1;

    if (daysRemaining <= 0) return 0;

    return remaining / daysRemaining;
  }

  Map<String, dynamic> toMap() {
    return {
      'targetAmount': targetAmount,
      'targetDate': targetDate.toIso8601String(),
      'createdDate': createdDate.toIso8601String(),
      'isCompleted': isCompleted,
      'isMissed': isMissed,
    };
  }
}
