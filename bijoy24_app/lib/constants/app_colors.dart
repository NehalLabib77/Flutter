import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF1A237E);
  static const Color primaryLight = Color(0xFF534bae);
  static const Color primaryDark = Color(0xFF000051);

  // Accent
  static const Color accent = Color(0xFFFFC107);
  static const Color accentLight = Color(0xFFFFF350);
  static const Color accentDark = Color(0xFFC79100);

  // Status Colors
  static const Color pending = Color(0xFFFF9800);
  static const Color approved = Color(0xFF4CAF50);
  static const Color active = Color(0xFF4CAF50);
  static const Color resolved = Color(0xFF4CAF50);
  static const Color available = Color(0xFF4CAF50);
  static const Color rejected = Color(0xFFF44336);
  static const Color inactive = Color(0xFFF44336);
  static const Color inProgress = Color(0xFF2196F3);
  static const Color booked = Color(0xFF2196F3);
  static const Color maintenance = Color(0xFF9E9E9E);
  static const Color reserved = Color(0xFF9C27B0);

  // Background
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;

  // Text
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Colors.white;
  static const Color textOnAccent = Color(0xFF212121);

  // Misc
  static const Color divider = Color(0xFFBDBDBD);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return pending;
      case 'approved':
      case 'active':
      case 'resolved':
      case 'available':
      case 'running':
        return approved;
      case 'rejected':
      case 'inactive':
      case 'expired':
      case 'cancelled':
        return rejected;
      case 'inprogress':
      case 'in_progress':
      case 'booked':
        return inProgress;
      case 'maintenance':
        return maintenance;
      case 'reserved':
        return reserved;
      default:
        return textSecondary;
    }
  }
}
