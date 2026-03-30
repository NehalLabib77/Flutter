import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/seat.dart';

class SeatLayoutWidget extends StatelessWidget {
  final List<Seat> seats;
  final Function(Seat seat)? onSeatTap;
  final String? roomNumber;

  const SeatLayoutWidget({
    super.key,
    required this.seats,
    this.onSeatTap,
    this.roomNumber,
  });

  Seat? _getSeatByType(String type) {
    try {
      return seats.firstWhere((s) => s.seatType == type);
    } catch (_) {
      return null;
    }
  }

  Color _seatColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return AppColors.available;
      case 'pending':
        return AppColors.pending;
      case 'booked':
        return AppColors.booked;
      case 'reserved':
        return AppColors.reserved;
      case 'maintenance':
        return AppColors.maintenance;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.window, size: 16, color: AppColors.info),
                SizedBox(width: 6),
                Text(
                  'Window Side',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildSeatTile(
                  _getSeatByType('WINDOW_LEFT'),
                  'Window Left',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSeatTile(
                  _getSeatByType('WINDOW_RIGHT'),
                  'Window Right',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (roomNumber != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Room $roomNumber',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildSeatTile(_getSeatByType('DOOR_LEFT'), 'Door Left'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSeatTile(
                  _getSeatByType('DOOR_RIGHT'),
                  'Door Right',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.brown.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.door_front_door,
                  size: 16,
                  color: Colors.brown.shade700,
                ),
                const SizedBox(width: 6),
                Text(
                  'Door Side',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.brown.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _legendItem(AppColors.available, 'Available'),
              _legendItem(AppColors.pending, 'Pending'),
              _legendItem(AppColors.booked, 'Booked'),
              _legendItem(AppColors.maintenance, 'Maintenance'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeatTile(Seat? seat, String label) {
    if (seat == null) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text('N/A', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final color = _seatColor(seat.status);
    final isAvailable = seat.status.toLowerCase() == 'available';

    return GestureDetector(
      onTap: isAvailable ? () => onSeatTap?.call(seat) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 80,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bed, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              seat.status,
              style: TextStyle(
                fontSize: 9,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: color),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}
