import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../providers/system_admin_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/confirmation_dialog.dart';

class ManageHallsScreen extends ConsumerStatefulWidget {
  const ManageHallsScreen({super.key});

  @override
  ConsumerState<ManageHallsScreen> createState() => _ManageHallsScreenState();
}

class _ManageHallsScreenState extends ConsumerState<ManageHallsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(sysAdminHallsProvider.notifier).fetch());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sysAdminHallsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Halls')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/system-admin/halls/create'),
        icon: const Icon(Icons.add),
        label: const Text('Add Hall'),
      ),
      body: state.when(
        data: (halls) {
          if (halls.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.apartment_outlined,
              title: 'No Halls Registered',
              subtitle: 'Tap + to add a new hall',
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(sysAdminHallsProvider.notifier).fetch(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: halls.length,
              itemBuilder: (ctx, i) {
                final hall = halls[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: hall.hallType == 'Male'
                          ? AppColors.primary
                          : Colors.pink.shade400,
                      child: const Icon(Icons.apartment, color: Colors.white),
                    ),
                    title: Text(
                      hall.hallName ?? 'Hall #${hall.hallId}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${hall.hallType ?? 'Mixed'} \u2022 Capacity: ${hall.hallCapacity}',
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (a) => _handleAction(a, hall.hallId),
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: false,
                  ),
                );
              },
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (_, __) => ErrorRetryWidget(
          message: 'Failed to load halls',
          onRetry: () => ref.read(sysAdminHallsProvider.notifier).fetch(),
        ),
      ),
    );
  }

  void _handleAction(String action, int hallId) {
    switch (action) {
      case 'edit':
        context.push('/system-admin/halls/edit/$hallId');
        break;
      case 'delete':
        _deleteHall(hallId);
        break;
    }
  }

  Future<void> _deleteHall(int hallId) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Delete Hall',
      message: 'Permanently delete this hall and all its rooms?',
      confirmText: 'Delete',
      confirmColor: AppColors.error,
    );
    if (confirmed == true) {
      await ref.read(sysAdminHallsProvider.notifier).delete(hallId);
    }
  }
}
