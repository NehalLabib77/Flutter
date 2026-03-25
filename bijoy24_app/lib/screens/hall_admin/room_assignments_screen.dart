import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../providers/hall_admin_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/status_badge.dart';

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
      appBar: const GradientAppBar(title: 'Room Assignments'),
      body: state.when(
        data: (assignments) {
          if (assignments.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.assignment_ind_rounded,
              title: 'No Assignments',
              subtitle: 'Room assignments will appear here',
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
                return AppCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primarySurface,
                        child: Text(
                          (a.studentName ?? 'S').substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.studentName ?? 'Student',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Room: ${a.roomIdentity} • ${a.faculty ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Since: ${a.assignmentDate.toString().split(' ').first}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StatusBadge(status: a.status),
                          const SizedBox(height: 8),
                          if (a.status == 'Active')
                            SizedBox(
                              height: 30,
                              child: TextButton(
                                onPressed: () => ref
                                    .read(hallAdminAssignmentsProvider.notifier)
                                    .unassign(a.assignmentId),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  foregroundColor: AppColors.error,
                                ),
                                child: const Text(
                                  'Unassign',
                                  style: TextStyle(fontSize: 12),
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
          message: 'Failed to load assignments',
          onRetry: () =>
              ref.read(hallAdminAssignmentsProvider.notifier).fetch(),
        ),
      ),
    );
  }
}
