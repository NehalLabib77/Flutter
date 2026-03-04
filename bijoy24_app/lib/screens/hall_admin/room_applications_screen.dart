import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../providers/hall_admin_provider.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/confirmation_dialog.dart';

class RoomApplicationsScreen extends ConsumerStatefulWidget {
  const RoomApplicationsScreen({super.key});

  @override
  ConsumerState<RoomApplicationsScreen> createState() =>
      _RoomApplicationsScreenState();
}

class _RoomApplicationsScreenState
    extends ConsumerState<RoomApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(hallAdminRoomAppsProvider.notifier).fetch(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hallAdminRoomAppsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Room Applications')),
      body: state.when(
        data: (apps) {
          if (apps.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.assignment_outlined,
              title: 'No Room Applications',
              subtitle: 'There are no pending room applications.',
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(hallAdminRoomAppsProvider.notifier).fetch(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: apps.length,
              itemBuilder: (context, i) {
                final app = apps[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.1,
                              ),
                              child: Text(
                                app.studentName?.isNotEmpty == true
                                    ? app.studentName![0]
                                    : '?',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    app.studentName ?? 'Unknown',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'ID: ${app.studentId}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            StatusBadge(status: app.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _chipInfo(Icons.school, app.faculty ?? 'N/A'),
                            const SizedBox(width: 12),
                            _chipInfo(
                              Icons.calendar_today,
                              'Sem ${app.semester ?? 0}',
                            ),
                            const Spacer(),
                            Text(
                              app.applicationDate.toString().split(' ')[0],
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        if (app.status == 'Pending') ...[
                          const Divider(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                    side: const BorderSide(
                                      color: AppColors.error,
                                    ),
                                  ),
                                  onPressed: () => _reject(app.applicationId),
                                  child: const Text('Reject'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.approved,
                                  ),
                                  onPressed: () => _approve(app.applicationId),
                                  child: const Text('Approve'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (_, __) => ErrorRetryWidget(
          message: 'Failed to load applications',
          onRetry: () => ref.read(hallAdminRoomAppsProvider.notifier).fetch(),
        ),
      ),
    );
  }

  Future<void> _approve(int id) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Approve Application',
      message: 'Are you sure you want to approve this room application?',
      confirmText: 'Approve',
      confirmColor: AppColors.approved,
    );
    if (confirmed == true) {
      await ref.read(hallAdminRoomAppsProvider.notifier).approve(id, {});
    }
  }

  Future<void> _reject(int id) async {
    final remarks = await showRemarksDialog(
      context,
      title: 'Reject Application',
      hintText: 'Reason for rejection (optional)',
    );
    if (remarks != null) {
      await ref.read(hallAdminRoomAppsProvider.notifier).reject(id, {
        'adminRemarks': remarks,
      });
    }
  }

  Widget _chipInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
