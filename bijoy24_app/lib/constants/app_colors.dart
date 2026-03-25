import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Palette — Deep Navy
  static const Color primary = Color(0xFF1A237E);
  static const Color primaryLight = Color(0xFF3949AB);
  static const Color primaryDark = Color(0xFF0D1547);
  static const Color primarySurface = Color(0xFFE8EAF6);

  // Accent — Warm Gold
  static const Color accent = Color(0xFFFFC107);
  static const Color accentLight = Color(0xFFFFECB3);
  static const Color accentDark = Color(0xFFF57F17);

  // Gradient Sets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFFC107), Color(0xFFFFD54F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Status — Semantic
  static const Color pending = Color(0xFFFF9800);
  static const Color approved = Color(0xFF43A047);
  static const Color active = Color(0xFF43A047);
  static const Color resolved = Color(0xFF43A047);
  static const Color available = Color(0xFF43A047);
  static const Color rejected = Color(0xFFE53935);
  static const Color inactive = Color(0xFFE53935);
  static const Color inProgress = Color(0xFF1E88E5);
  static const Color booked = Color(0xFF1E88E5);
  static const Color maintenance = Color(0xFF78909C);
  static const Color reserved = Color(0xFF8E24AA);

  // Surfaces
  static const Color background = Color(0xFFF5F6FA);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;

  // Text
  static const Color textPrimary = Color(0xFF1A1D26);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Colors.white;
  static const Color textOnAccent = Color(0xFF1A1D26);

  // Misc
  static const Color divider = Color(0xFFE5E7EB);
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFEA580C);
  static const Color info = Color(0xFF2563EB);

  // Soft Tints
  static Color get pendingBg => pending.withValues(alpha: 0.10);
  static Color get approvedBg => approved.withValues(alpha: 0.10);
  static Color get rejectedBg => rejected.withValues(alpha: 0.10);
  static Color get infoBg => info.withValues(alpha: 0.10);
  static Color get warningBg => warning.withValues(alpha: 0.10);
  static Color get errorBg => error.withValues(alpha: 0.10);
  static Color get successBg => success.withValues(alpha: 0.10);

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

  static Color getStatusBg(String status) {
    return getStatusColor(status).withValues(alpha: 0.10);
  }
}
