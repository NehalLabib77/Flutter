import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../providers/hall_admin_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/status_badge.dart';
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
      appBar: const GradientAppBar(title: 'Room Change Requests'),
      body: state.when(
        data: (requests) {
          if (requests.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.swap_horiz_rounded,
              title: 'No Requests',
              subtitle: 'Room change requests will appear here',
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
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.pendingBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.swap_horiz_rounded,
                              color: AppColors.pending,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  req.studentName ?? 'Student',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  '${req.currentRoom ?? 'Current'} → ${req.requestedRoomNumber ?? req.requestedRoomId}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(status: req.status),
                        ],
                      ),
                      if (req.reason != null && req.reason!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            req.reason!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        'Requested: ${req.requestDate.toString().split(' ').first}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      if (req.status == 'Pending') ...[
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    _process(req.requestId, 'Rejected'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(
                                    color: AppColors.error,
                                  ),
                                ),
                                child: const Text('Reject'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: () =>
                                    _process(req.requestId, 'Approved'),
                                child: const Text('Approve'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (_, _) => ErrorRetryWidget(
          message: 'Failed to load room change requests',
          onRetry: () => ref.read(hallAdminRoomChangeProvider.notifier).fetch(),
        ),
      ),
    );
  }

  Future<void> _process(int id, String status) async {
    final remarks = await showRemarksDialog(
      context,
      title: '$status — Add Remarks',
    );
    if (remarks != null) {
      await ref.read(hallAdminRoomChangeProvider.notifier).process(id, {
        'status': status,
        'adminRemarks': remarks,
      });
    }
  }
}
