import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../providers/student_provider.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';

class MaintenanceListScreen extends ConsumerStatefulWidget {
  const MaintenanceListScreen({super.key});

  @override
  ConsumerState<MaintenanceListScreen> createState() =>
      _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends ConsumerState<MaintenanceListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(studentMaintenanceProvider.notifier).fetch(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studentMaintenanceProvider);

    return Scaffold(
      appBar: const GradientAppBar(title: 'My Maintenance Requests'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/student/submit-maintenance'),
        child: const Icon(Icons.add),
      ),
      body: state.when(
        data: (requests) {
          if (requests.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.build_circle_outlined,
              title: 'No Maintenance Requests',
              subtitle: 'You haven\'t submitted any maintenance requests yet.',
              actionLabel: 'Report Issue',
              onAction: () => context.push('/student/submit-maintenance'),
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(studentMaintenanceProvider.notifier).fetch(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, i) {
                final r = requests[i];
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
                                'Request #${r.requestId}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            StatusBadge(status: r.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          r.issue,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _priorityColor(
                                  r.priority,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                r.priority,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _priorityColor(r.priority),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              r.submittedOn.toString().split(' ')[0],
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        if (r.technicianNote != null) ...[
                          const Divider(height: 16),
                          Row(
                            children: [
                              const Icon(
                                Icons.engineering,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  r.technicianNote!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (r.resolvedOn != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Resolved: ${r.resolvedOn.toString().split(' ')[0]}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.success,
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
          message: 'Failed to load maintenance requests',
          onRetry: () => ref.read(studentMaintenanceProvider.notifier).fetch(),
        ),
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return AppColors.error;
      case 'high':
        return AppColors.warning;
      case 'medium':
        return AppColors.accent;
      case 'low':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }
}
