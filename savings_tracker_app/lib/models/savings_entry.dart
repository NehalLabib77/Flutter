import 'package:hive_flutter/hive_flutter.dart';

part 'savings_entry.g.dart';

@HiveType(typeId: 0)
class SavingsEntry extends HiveObject {
  @HiveField(0)
  late DateTime date;

  @HiveField(1)
  late double amount;

  @HiveField(2)
  late String? note;

  SavingsEntry({required this.date, required this.amount, this.note});

  Map<String, dynamic> toMap() {
    return {'date': date.toIso8601String(), 'amount': amount, 'note': note};
  }
}
