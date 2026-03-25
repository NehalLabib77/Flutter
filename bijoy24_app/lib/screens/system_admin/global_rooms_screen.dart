import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../providers/hall_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state_widget.dart';

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
    final roomsState = _selectedHallId != null
        ? ref.watch(roomListProvider)
        : null;

    return Scaffold(
      appBar: const GradientAppBar(title: 'All Rooms'),
      body: Column(
        children: [
          // Hall picker
          hallsState.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(),
            ),
            error: (_, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Error loading halls',
                style: TextStyle(color: Colors.red.shade600),
              ),
            ),
            data: (halls) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: DropdownButtonFormField<int>(
                initialValue: _selectedHallId,
                decoration: const InputDecoration(
                  labelText: 'Select Hall',
                  prefixIcon: Icon(Icons.apartment_rounded),
                ),
                items: halls
                    .map(
                      (h) => DropdownMenuItem(
                        value: h.hallId,
                        child: Text(h.hallName),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() => _selectedHallId = v);
                  if (v != null) {
                    ref.read(roomListProvider.notifier).fetchForHall(v);
                  }
                },
              ),
            ),
          ),

          const Divider(height: 1),

          // Room list
          Expanded(
            child: _selectedHallId == null
                ? const EmptyStateWidget(
                    icon: Icons.meeting_room_rounded,
                    title: 'Select a Hall',
                    subtitle: 'Choose a hall above to view its rooms.',
                  )
                : roomsState == null
                ? const LoadingWidget()
                : roomsState.when(
                    loading: () => const LoadingWidget(),
                    error: (_, _) => ErrorRetryWidget(
                      message: 'Failed to load rooms',
                      onRetry: () => ref
                          .read(roomListProvider.notifier)
                          .fetchForHall(_selectedHallId!),
                    ),
                    data: (rooms) {
                      if (rooms.isEmpty) {
                        return const EmptyStateWidget(
                          icon: Icons.meeting_room_outlined,
                          title: 'No Rooms',
                          subtitle: 'This hall has no rooms yet.',
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: rooms.length,
                        itemBuilder: (ctx, i) {
                          final r = rooms[i];
                          final occupancy = r.roomCapacity > 0
                              ? (r.roomCapacity - r.availableSlots) /
                                    r.roomCapacity
                              : 0.0;
                          return AppCard(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.door_front_door_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.roomIdentity,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.people_rounded,
                                            size: 14,
                                            color: Colors.grey.shade500,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${r.roomCapacity - r.availableSlots}/${r.roomCapacity}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: LinearProgressIndicator(
                                                value: occupancy,
                                                minHeight: 5,
                                                backgroundColor:
                                                    Colors.grey.shade200,
                                                color: occupancy > 0.9
                                                    ? Colors.red
                                                    : occupancy > 0.6
                                                    ? Colors.orange
                                                    : AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusBadge(status: r.status, fontSize: 10),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
