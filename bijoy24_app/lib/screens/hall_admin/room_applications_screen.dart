import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../providers/hall_admin_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/status_badge.dart';

class RoomApplicationsScreen extends ConsumerStatefulWidget {
  const RoomApplicationsScreen({super.key});

  @override
  ConsumerState<RoomApplicationsScreen> createState() =>
      _RoomApplicationsScreenState();
}

class _RoomApplicationsScreenState
    extends ConsumerState<RoomApplicationsScreen> {
  String _searchQuery = '';

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
      appBar: const GradientAppBar(title: 'Room Applications'),
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
              icon: Icons.inbox_rounded,
              title: 'No Applications',
              subtitle: 'Room applications will appear here',
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
                child: RefreshIndicator(
                  onRefresh: () =>
                      ref.read(hallAdminRoomAppsProvider.notifier).fetch(),
                  child: filtered.isEmpty
                      ? const EmptyStateWidget(
                          icon: Icons.search_off_rounded,
                          title: 'No Results',
                          subtitle: 'No applications match your search',
                        )
                      : ListView.builder(
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
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor:
                                            AppColors.primarySurface,
                                        child: Text(
                                          (app.studentName ?? 'S')
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
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
                                              'ID: ${app.studentId}',
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
                                          child: OutlinedButton.icon(
                                            onPressed: () => ref
                                                .read(
                                                  hallAdminRoomAppsProvider
                                                      .notifier,
                                                )
                                                .reject(app.applicationId, {
                                                  'status': 'Rejected',
                                                }),
                                            icon: const Icon(
                                              Icons.close_rounded,
                                              size: 18,
                                            ),
                                            label: const Text('Reject'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppColors.error,
                                              side: const BorderSide(
                                                color: AppColors.error,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: FilledButton.icon(
                                            onPressed: () => ref
                                                .read(
                                                  hallAdminRoomAppsProvider
                                                      .notifier,
                                                )
                                                .approve(app.applicationId, {
                                                  'status': 'Approved',
                                                }),
                                            icon: const Icon(
                                              Icons.check_rounded,
                                              size: 18,
                                            ),
                                            label: const Text('Approve'),
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
          message: 'Failed to load applications',
          onRetry: () => ref.read(hallAdminRoomAppsProvider.notifier).fetch(),
        ),
      ),
    );
  }
}
