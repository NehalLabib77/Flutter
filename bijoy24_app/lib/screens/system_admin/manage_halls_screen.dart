import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../providers/system_admin_provider.dart';
import '../../widgets/app_card.dart';
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
      appBar: const GradientAppBar(title: 'Manage Halls'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/system-admin/halls/create'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Hall'),
      ),
      body: state.when(
        data: (halls) {
          if (halls.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.apartment_outlined,
              title: 'No Halls',
              subtitle: 'Add a residential hall to get started',
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(sysAdminHallsProvider.notifier).fetch(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: halls.length,
              itemBuilder: (ctx, i) {
                final hall = halls[i];
                return AppCard(
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            hall.hallName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hall.hallName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${hall.hallType} • Capacity: ${hall.hallCapacity}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (hall.location != null)
                              Text(
                                hall.location!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (a) => _handleAction(a, hall.hallId),
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
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
                );
              },
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (_, _) => ErrorRetryWidget(
          message: 'Failed to load halls',
          onRetry: () => ref.read(sysAdminHallsProvider.notifier).fetch(),
        ),
      ),
    );
  }

  void _handleAction(String action, int hallId) {
    if (action == 'edit') {
      context.push('/system-admin/halls/edit/$hallId');
    } else if (action == 'delete') {
      _deleteHall(hallId);
    }
  }

  Future<void> _deleteHall(int id) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Delete Hall',
      message: 'This will permanently remove this hall. Continue?',
      confirmText: 'Delete',
      confirmColor: AppColors.error,
    );
    if (confirmed == true) {
      await ref.read(sysAdminHallsProvider.notifier).delete(id);
    }
  }
}
