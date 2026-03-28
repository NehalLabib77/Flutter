import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Enum for seat positions in a room (4 positions based on door and window locations)
enum SeatPosition {
  leftDoor('Left Door', Icons.door_back_door_rounded, 'DOOR_LEFT'),
  rightDoor('Right Door', Icons.door_back_door_rounded, 'DOOR_RIGHT'),
  leftWindow('Left Window', Icons.window_rounded, 'WINDOW_LEFT'),
  rightWindow('Right Window', Icons.window_rounded, 'WINDOW_RIGHT');

  final String label;
  final IconData icon;
  final String apiValue;

  const SeatPosition(this.label, this.icon, this.apiValue);

  /// Get a display name for the position
  String get displayName => label;

  /// Convert string to enum (from API value)
  static SeatPosition? fromString(String? value) {
    if (value == null) return null;
    try {
      return SeatPosition.values.firstWhere(
        (e) => e.apiValue == value || e.name == value,
      );
    } catch (_) {
      return null;
    }
  }

  /// Convert to API value for backend
  String toApiValue() => apiValue;
}

/// A widget that displays 4 selectable seat positions
/// Shows positions in a 2x2 grid: left door, right door, left window, right window
class SeatPositionSelector extends StatelessWidget {
  final SeatPosition? selectedPosition;
  final ValueChanged<SeatPosition> onSelect;
  final bool enabled;
  final String? title;

  const SeatPositionSelector({
    super.key,
    required this.onSelect,
    this.selectedPosition,
    this.enabled = true,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
        ],
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.5,
          physics: const NeverScrollableScrollPhysics(),
          children: SeatPosition.values.map((position) {
            final isSelected = selectedPosition == position;
            return _SeatPositionTile(
              position: position,
              isSelected: isSelected,
              onTap: enabled ? () => onSelect(position) : null,
              enabled: enabled,
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Individual tile for a seat position
class _SeatPositionTile extends StatelessWidget {
  final SeatPosition position;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool enabled;

  const _SeatPositionTile({
    required this.position,
    required this.isSelected,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: isSelected ? 2.5 : 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? AppColors.primarySurface : AppColors.surface,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                position.icon,
                size: 28,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                position.displayName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
