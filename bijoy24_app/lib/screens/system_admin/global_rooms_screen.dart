import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../providers/hall_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';

class GlobalRoomsScreen extends ConsumerStatefulWidget {
  const GlobalRoomsScreen({super.key});

  @override
  ConsumerState<GlobalRoomsScreen> createState() => _GlobalRoomsScreenState();
}

class _GlobalRoomsScreenState extends ConsumerState<GlobalRoomsScreen> {
  int? _selectedHallId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(hallListProvider.notifier).fetch());
  }

  @override
  Widget build(BuildContext context) {
    final hallsState = ref.watch(hallListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Global Rooms View')),
      body: Column(
        children: [
          // Hall selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: hallsState.when(
              data: (halls) => DropdownButtonFormField<int>(
                value: _selectedHallId,
                decoration: const InputDecoration(
                  labelText: 'Select Hall',
                  prefixIcon: Icon(Icons.apartment),
                ),
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('All Halls'),
                  ),
                  ...halls.map(
                    (h) => DropdownMenuItem(
                      value: h.hallId,
                      child: Text(h.hallName ?? 'Hall #${h.hallId}'),
                    ),
                  ),
                ],
                onChanged: (v) {
                  setState(() => _selectedHallId = v);
                  if (v != null) {
                    ref.read(roomListProvider.notifier).fetchForHall(v);
                  }
                },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Failed to load halls'),
            ),
          ),
          // Room list
          Expanded(
            child: _selectedHallId == null
                ? const EmptyStateWidget(
                    icon: Icons.search,
                    title: 'Select a Hall',
                    subtitle: 'Choose a hall above to view its rooms',
                  )
                : _buildRoomList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomList() {
    final roomsState = ref.watch(roomListProvider);
    return roomsState.when(
      data: (rooms) {
        if (rooms.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.meeting_room_outlined,
            title: 'No Rooms',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: rooms.length,
          itemBuilder: (ctx, i) {
            final room = rooms[i];
            final occ = room.roomCapacity - room.availableSlots;
            final cap = room.roomCapacity;
            final pct = cap > 0 ? occ / cap : 0.0;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: pct >= 1
                      ? AppColors.error
                      : AppColors.approved,
                  child: Text(
                    room.roomNumber ?? '-',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(room.roomName ?? 'Room ${room.roomNumber}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Floor ${room.floor ?? '-'} • ${room.wing ?? '-'} Wing • Block ${room.block ?? '-'}',
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: pct,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(
                        pct >= 1.0 ? AppColors.error : AppColors.primary,
                      ),
                    ),
                    Text('$occ / $cap', style: const TextStyle(fontSize: 11)),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
      loading: () => const LoadingWidget(),
      error: (_, __) => ErrorRetryWidget(
        message: 'Failed to load rooms',
        onRetry: () {
          if (_selectedHallId != null) {
            ref.read(roomListProvider.notifier).fetchForHall(_selectedHallId!);
          }
        },
      ),
    );
  }
}
