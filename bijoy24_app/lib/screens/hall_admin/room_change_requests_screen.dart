import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../providers/hall_admin_provider.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/confirmation_dialog.dart';

class RoomChangeRequestsScreen extends ConsumerStatefulWidget {
  const RoomChangeRequestsScreen({super.key});

  @override
  ConsumerState<RoomChangeRequestsScreen> createState() =>
      _RoomChangeRequestsScreenState();
}

class _RoomChangeRequestsScreenState
    extends ConsumerState<RoomChangeRequestsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(hallAdminRoomChangeProvider.notifier).fetch(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hallAdminRoomChangeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Room Change Requests')),
      body: state.when(
        data: (requests) {
          if (requests.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.swap_horiz,
              title: 'No Room Change Requests',
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(hallAdminRoomChangeProvider.notifier).fetch(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (ctx, i) {
                final req = requests[i];
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
                            Expanded(
                              child: Text(
                                req.studentName ?? 'Student #${req.studentId}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            StatusBadge(status: req.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _roomCard(
                                'Current',
                                'Room ${req.currentRoom ?? '-'}',
                                AppColors.error.withValues(alpha: 0.1),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                Icons.arrow_forward,
                                color: AppColors.primary,
                              ),
                            ),
                            Expanded(
                              child: _roomCard(
                                'Requested',
                                'Room ${req.requestedRoomNumber ?? req.requestedRoomId}',
                                AppColors.approved.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Reason: ${req.reason ?? 'N/A'}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        Text(
                          'Date: ${req.requestDate.toString().split(' ')[0]}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (req.status == 'Pending') ...[
                          const Divider(height: 16),
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
                                  onPressed: () => _reject(req.requestId),
                                  child: const Text('Reject'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.approved,
                                  ),
                                  onPressed: () => _approve(req.requestId),
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
          message: 'Failed to load room change requests',
          onRetry: () => ref.read(hallAdminRoomChangeProvider.notifier).fetch(),
        ),
      ),
    );
  }

  Widget _roomCard(String label, String room, Color bg) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          Text(room, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _approve(int id) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Approve Room Change',
      message: 'Approve this room change request?',
      confirmText: 'Approve',
      confirmColor: AppColors.approved,
    );
    if (confirmed == true) {
      await ref.read(hallAdminRoomChangeProvider.notifier).process(id, {
        'status': 'Approved',
      });
    }
  }

  Future<void> _reject(int id) async {
    final remarks = await showRemarksDialog(
      context,
      title: 'Reject Room Change',
    );
    if (remarks != null) {
      await ref.read(hallAdminRoomChangeProvider.notifier).process(id, {
        'status': 'Rejected',
        'adminRemarks': remarks,
      });
    }
  }
}
