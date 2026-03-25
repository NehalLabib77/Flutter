import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../providers/hall_admin_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/status_badge.dart';

class SeatApplicationsScreen extends ConsumerStatefulWidget {
  const SeatApplicationsScreen({super.key});

  @override
  ConsumerState<SeatApplicationsScreen> createState() =>
      _SeatApplicationsScreenState();
}

class _SeatApplicationsScreenState
    extends ConsumerState<SeatApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(hallAdminSeatAppsProvider.notifier).fetch(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hallAdminSeatAppsProvider);

    return Scaffold(
      appBar: const GradientAppBar(title: 'Seat Applications'),
      body: state.when(
        data: (apps) {
          if (apps.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.event_seat_rounded,
              title: 'No Seat Applications',
              subtitle: 'Seat booking requests will appear here',
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(hallAdminSeatAppsProvider.notifier).fetch(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: apps.length,
              itemBuilder: (ctx, i) {
                final app = apps[i];
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
                              color: AppColors.infoBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.event_seat_rounded,
                              color: AppColors.info,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  app.studentName ?? 'Student',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  'Seat: ${app.seatType} • Room: ${app.roomId}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(status: app.status),
                        ],
                      ),
                      if (app.status == 'Pending') ...[
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => ref
                                    .read(hallAdminSeatAppsProvider.notifier)
                                    .reject(app.applicationId, {
                                      'status': 'Rejected',
                                    }),
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
                                onPressed: () => ref
                                    .read(hallAdminSeatAppsProvider.notifier)
                                    .approve(app.applicationId, {
                                      'status': 'Approved',
                                    }),
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
          message: 'Failed to load seat applications',
          onRetry: () => ref.read(hallAdminSeatAppsProvider.notifier).fetch(),
        ),
      ),
    );
  }
}
