import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../providers/hall_admin_provider.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/confirmation_dialog.dart';

class SeatApplicationsScreen extends ConsumerStatefulWidget {
  const SeatApplicationsScreen({super.key});

  @override
  ConsumerState<SeatApplicationsScreen> createState() =>
      _SeatApplicationsScreenState();
}

class _SeatApplicationsScreenState extends ConsumerState<SeatApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _filters = ['All', 'Pending', 'Approved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _filters.length, vsync: this);
    Future.microtask(
      () => ref.read(hallAdminSeatAppsProvider.notifier).fetch(),
    );
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hallAdminSeatAppsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seat Applications'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.accent,
          tabs: _filters.map((f) => Tab(text: f)).toList(),
        ),
      ),
      body: state.when(
        data: (apps) {
          return TabBarView(
            controller: _tabCtrl,
            children: _filters.map((filter) {
              final filtered = filter == 'All'
                  ? apps
                  : apps.where((a) => a.status == filter).toList();
              if (filtered.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.event_seat_outlined,
                  title: 'No $filter Applications',
                );
              }
              return RefreshIndicator(
                onRefresh: () =>
                    ref.read(hallAdminSeatAppsProvider.notifier).fetch(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final app = filtered[i];
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
                                    app.studentName ??
                                        'Student ${app.studentId}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                StatusBadge(status: app.status),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Room: ${app.roomNumber ?? app.roomId}'),
                            Text(
                              'Seat: ${app.seatType ?? 'N/A'} (#${app.seatNumber ?? 0})',
                            ),
                            Text(
                              'Date: ${app.applicationDate.toString().split(' ')[0]}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (app.studentRemarks != null)
                              Text(
                                'Student: ${app.studentRemarks}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            if (app.status == 'Pending') ...[
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
                                      onPressed: () =>
                                          _reject(app.applicationId),
                                      child: const Text('Reject'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.approved,
                                      ),
                                      onPressed: () =>
                                          _approve(app.applicationId),
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
            }).toList(),
          );
        },
        loading: () => const LoadingWidget(),
        error: (_, __) => ErrorRetryWidget(
          message: 'Failed to load seat applications',
          onRetry: () => ref.read(hallAdminSeatAppsProvider.notifier).fetch(),
        ),
      ),
    );
  }

  Future<void> _approve(int id) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Approve Seat Application',
      message: 'Approve this seat booking?',
      confirmText: 'Approve',
      confirmColor: AppColors.approved,
    );
    if (confirmed == true) {
      await ref.read(hallAdminSeatAppsProvider.notifier).approve(id, {});
    }
  }

  Future<void> _reject(int id) async {
    final remarks = await showRemarksDialog(
      context,
      title: 'Reject Seat Application',
    );
    if (remarks != null) {
      await ref.read(hallAdminSeatAppsProvider.notifier).reject(id, {
        'adminRemarks': remarks,
      });
    }
  }
}
