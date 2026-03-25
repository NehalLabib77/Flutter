import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../providers/hall_admin_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/confirmation_dialog.dart';

class ManageRoomsScreen extends ConsumerStatefulWidget {
  const ManageRoomsScreen({super.key});

  @override
  ConsumerState<ManageRoomsScreen> createState() => _ManageRoomsScreenState();
}

class _ManageRoomsScreenState extends ConsumerState<ManageRoomsScreen> {
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(hallAdminRoomsProvider.notifier).fetch());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hallAdminRoomsProvider);

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Manage Rooms',
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded),
            onSelected: (v) => setState(() => _filter = v),
            itemBuilder: (_) => [
              'All',
              'Available',
              'Full',
              'Maintenance',
            ].map((s) => PopupMenuItem(value: s, child: Text(s))).toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/hall-admin/rooms/create'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Room'),
      ),
      body: state.when(
        data: (rooms) {
          final filtered = _filter == 'All'
              ? rooms
              : rooms.where((r) => r.status == _filter).toList();
          if (filtered.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.meeting_room_outlined,
              title: 'No Rooms Found',
              subtitle: 'Tap + to add a new room',
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(hallAdminRoomsProvider.notifier).fetch(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final room = filtered[i];
                final occupied = room.roomCapacity - room.availableSlots;
                final pct = room.roomCapacity > 0
                    ? occupied / room.roomCapacity
                    : 0.0;
                return AppCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _roomIcon(room.status, room.roomNumber),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  room.roomName ??
                                      'Room ${room.roomNumber ?? room.roomId}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Floor ${room.floor ?? '-'} • ${room.wing ?? '-'} Wing',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (a) => _handleAction(a, room.roomId),
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              const PopupMenuItem(
                                value: 'members',
                                child: Text('View Members'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  'Delete',
                                  style: TextStyle(color: AppColors.error),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 6,
                          backgroundColor: AppColors.divider,
                          valueColor: AlwaysStoppedAnimation(
                            pct >= 1.0 ? AppColors.error : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$occupied / ${room.roomCapacity} occupied',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.getStatusBg(room.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              room.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.getStatusColor(room.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (_, _) => ErrorRetryWidget(
          message: 'Failed to load rooms',
          onRetry: () => ref.read(hallAdminRoomsProvider.notifier).fetch(),
        ),
      ),
    );
  }

  Widget _roomIcon(String status, String? number) {
    final color = AppColors.getStatusColor(status);
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          number ?? '-',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }

  void _handleAction(String action, String roomId) {
    switch (action) {
      case 'edit':
        context.push('/hall-admin/rooms/edit/$roomId');
        break;
      case 'members':
        context.push('/hall-admin/rooms/$roomId/members');
        break;
      case 'delete':
        _deleteRoom(roomId);
        break;
    }
  }

  Future<void> _deleteRoom(String roomId) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Delete Room',
      message: 'This will permanently delete the room. Continue?',
      confirmText: 'Delete',
      confirmColor: AppColors.error,
    );
    if (confirmed == true) {
      await ref.read(hallAdminRoomsProvider.notifier).delete(roomId);
    }
  }
}
