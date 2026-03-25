import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../models/seat.dart';
import '../../providers/hall_provider.dart';
import '../../providers/student_provider.dart';
import '../../widgets/seat_layout_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';

class SeatBookingScreen extends ConsumerStatefulWidget {
  const SeatBookingScreen({super.key});

  @override
  ConsumerState<SeatBookingScreen> createState() => _SeatBookingScreenState();
}

class _SeatBookingScreenState extends ConsumerState<SeatBookingScreen> {
  int? _selectedHallId;
  String? _selectedRoomId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(hallListProvider.notifier).fetch());
  }

  void _onSeatTap(Seat seat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Seat ${seat.seatNumber} - ${seat.seatTypeDisplay}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${seat.seatTypeDisplay}'),
            Text('Status: ${seat.status}'),
            const SizedBox(height: 16),
            TextField(
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Remarks (optional)',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref
                  .read(seatApplicationProvider.notifier)
                  .submit({
                    'seatId': seat.seatId,
                    'hallId': seat.hallId,
                    'roomId': seat.roomId,
                  });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Seat application submitted!'
                          : 'Failed to apply. You may already have a pending application.',
                    ),
                    backgroundColor: success
                        ? AppColors.success
                        : AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Apply for This Seat'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hallsState = ref.watch(hallListProvider);
    final roomsState = ref.watch(roomListProvider);
    final seatsState = ref.watch(seatListProvider);

    return Scaffold(
      appBar: const GradientAppBar(title: 'Seat Booking'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hall selection
            hallsState.when(
              data: (halls) => DropdownButtonFormField<int>(
                initialValue: _selectedHallId,
                decoration: const InputDecoration(labelText: 'Select Hall'),
                items: halls
                    .map(
                      (h) => DropdownMenuItem(
                        value: h.hallId,
                        child: Text('${h.hallName} (${h.hallType})'),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedHallId = v;
                    _selectedRoomId = null;
                  });
                  if (v != null) {
                    ref.read(roomListProvider.notifier).fetchForHall(v);
                  }
                },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Failed to load halls'),
            ),
            const SizedBox(height: 16),

            // Room selection
            if (_selectedHallId != null)
              roomsState.when(
                data: (rooms) {
                  final available = rooms
                      .where((r) => r.status == 'Available')
                      .toList();
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedRoomId,
                    decoration: const InputDecoration(labelText: 'Select Room'),
                    items: available
                        .map(
                          (r) => DropdownMenuItem(
                            value: r.roomId,
                            child: Text(
                              'Room ${r.roomNumber ?? r.roomId} (${r.wing ?? ''}) - ${r.availableSlots} slots',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() => _selectedRoomId = v);
                      if (v != null && _selectedHallId != null) {
                        ref
                            .read(seatListProvider.notifier)
                            .fetch(v, _selectedHallId!);
                      }
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Failed to load rooms'),
              ),
            const SizedBox(height: 24),

            // Seat Layout
            if (_selectedRoomId != null)
              seatsState.when(
                data: (seats) {
                  if (seats.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.event_seat,
                      title: 'No Seats Found',
                      subtitle: 'This room has no available seats.',
                    );
                  }
                  return SeatLayoutWidget(
                    seats: seats,
                    onSeatTap: _onSeatTap,
                    roomNumber: _selectedRoomId,
                  );
                },
                loading: () => const LoadingWidget(),
                error: (_, __) => const Text('Failed to load seats'),
              ),

            if (_selectedRoomId == null && _selectedHallId != null)
              const EmptyStateWidget(
                icon: Icons.event_seat,
                title: 'Select a Room',
                subtitle: 'Choose a room to view its seat layout',
              ),
          ],
        ),
      ),
    );
  }
}
