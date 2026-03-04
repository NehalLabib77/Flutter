import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../providers/hall_admin_provider.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/confirmation_dialog.dart';

class RoomAssignmentsScreen extends ConsumerStatefulWidget {
  const RoomAssignmentsScreen({super.key});

  @override
  ConsumerState<RoomAssignmentsScreen> createState() =>
      _RoomAssignmentsScreenState();
}

class _RoomAssignmentsScreenState extends ConsumerState<RoomAssignmentsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(hallAdminAssignmentsProvider.notifier).fetch(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hallAdminAssignmentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Room Assignments')),
      body: state.when(
        data: (assignments) {
          if (assignments.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.assignment_outlined,
              title: 'No Active Assignments',
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(hallAdminAssignmentsProvider.notifier).fetch(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: assignments.length,
              itemBuilder: (ctx, i) {
                final a = assignments[i];
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
                            const Icon(Icons.person, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                a.studentName ?? 'Student #${a.studentId}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            StatusBadge(status: a.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _chip(
                              Icons.meeting_room,
                              'Room ${a.roomIdentity}',
                            ),
                            if (a.faculty != null) ...[
                              const SizedBox(width: 12),
                              _chip(
                                Icons.school,
                                a.faculty!,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Assigned: ${a.assignmentDate.toString().split(' ')[0]}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (a.status == 'Active') ...[
                          const Divider(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.error,
                              ),
                              icon: const Icon(Icons.person_remove, size: 18),
                              label: const Text('Unassign'),
                              onPressed: () => _unassign(a.assignmentId),
                            ),
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
          message: 'Failed to load assignments',
          onRetry: () =>
              ref.read(hallAdminAssignmentsProvider.notifier).fetch(),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Future<void> _unassign(int id) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Unassign Student',
      message: 'Remove this student from their room and seat?',
      confirmText: 'Unassign',
      confirmColor: AppColors.error,
    );
    if (confirmed == true) {
      await ref.read(hallAdminAssignmentsProvider.notifier).unassign(id);
    }
  }
}
