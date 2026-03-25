import 'package:flutter/material.dart';

class Task {
  final int id;
  String title;
  bool isDone;
  final Color color;
  DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    required this.color,
    this.isDone = false,
    this.completedAt,
  });

  void toggle() {
    isDone = !isDone;
    completedAt = isDone ? DateTime.now() : null;
  }
}
