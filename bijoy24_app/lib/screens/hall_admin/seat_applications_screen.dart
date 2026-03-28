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
  String _searchQuery = '';

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
          final filtered = _searchQuery.isEmpty
              ? apps
              : apps.where((app) {
                  final q = _searchQuery.toLowerCase();
                  return (app.studentName?.toLowerCase().contains(q) ??
                          false) ||
                      (app.studentId.toLowerCase().contains(q));
                }).toList();

          if (apps.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.event_seat_rounded,
              title: 'No Seat Applications',
              subtitle: 'Seat booking requests will appear here',
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name or student ID...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.search_off_rounded,
                        title: 'No Results',
                        subtitle: _searchQuery.isNotEmpty
                            ? 'No applications match your search'
                            : 'No seat applications available',
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref
                            .read(hallAdminSeatAppsProvider.notifier)
                            .fetch(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) {
                            final app = filtered[i];
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                            if (app.studentRemarks != null &&
                                                app
                                                    .studentRemarks!
                                                    .isNotEmpty) ...[
                                              const SizedBox(height: 6),
                                              Text(
                                                'Reason: ${app.studentRemarks}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
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
                                                .read(
                                                  hallAdminSeatAppsProvider
                                                      .notifier,
                                                )
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
                                                .read(
                                                  hallAdminSeatAppsProvider
                                                      .notifier,
                                                )
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
                      ),
              ),
            ],
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
