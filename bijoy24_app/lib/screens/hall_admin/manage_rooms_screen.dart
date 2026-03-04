import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../providers/hall_admin_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/confirmation_dialog.dart';

class ManageRoomsScreen extends ConsumerStatefulWidget {
  const ManageRoomsScreen({super.key});

  @override
  ConsumerState<ManageRoomsScreen> createState() => _ManageRoomsScreenState();
}

class _ManageRoomsScreenState extends ConsumerState<ManageRoomsScreen> {
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(hallAdminRoomsProvider.notifier).fetch(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hallAdminRoomsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Rooms'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (v) => setState(() => _statusFilter = v),
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
        icon: const Icon(Icons.add),
        label: const Text('Add Room'),
      ),
      body: state.when(
        data: (rooms) {
          final filtered = _statusFilter == 'All'
              ? rooms
              : rooms.where((r) => r.status == _statusFilter).toList();
          if (filtered.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.meeting_room_outlined,
              title: 'No Rooms Found',
              subtitle: 'Tap + to add a new room',
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(hallAdminRoomsProvider.notifier).fetch(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final room = filtered[i];
                final occupancy = room.roomCapacity - room.availableSlots;
                final capacity = room.roomCapacity;
                final pct = capacity > 0 ? occupancy / capacity : 0.0;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _statusColor(room.status),
                      child: Text(
                        room.roomNumber ?? '-',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    title: Text(
                      room.roomName ?? 'Room ${room.roomNumber}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
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
                            pct >= 1 ? AppColors.error : AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$occupancy / $capacity occupied',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) =>
                          _handleAction(action, room.roomId),
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'members',
                          child: Text('View Members'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (_, __) => ErrorRetryWidget(
          message: 'Failed to load rooms',
          onRetry: () => ref.read(hallAdminRoomsProvider.notifier).fetch(),
        ),
      ),
    );
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'Available':
        return AppColors.approved;
      case 'Full':
        return AppColors.error;
      case 'Maintenance':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
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
      message:
          'This will permanently delete the room and displace any assigned students. Continue?',
      confirmText: 'Delete',
      confirmColor: AppColors.error,
    );
    if (confirmed == true) {
      await ref.read(hallAdminRoomsProvider.notifier).delete(roomId);
    }
  }
}
