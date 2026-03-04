import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../providers/hall_admin_provider.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';

class MaintenanceRequestsScreen extends ConsumerStatefulWidget {
  const MaintenanceRequestsScreen({super.key});

  @override
  ConsumerState<MaintenanceRequestsScreen> createState() =>
      _MaintenanceRequestsScreenState();
}

class _MaintenanceRequestsScreenState
    extends ConsumerState<MaintenanceRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _tabs = ['All', 'Pending', 'In Progress', 'Resolved'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    Future.microtask(
      () => ref.read(hallAdminMaintenanceProvider.notifier).fetch(),
    );
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hallAdminMaintenanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Requests'),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          indicatorColor: AppColors.accent,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: state.when(
        data: (requests) {
          return TabBarView(
            controller: _tabCtrl,
            children: _tabs.map((tab) {
              final filtered = tab == 'All'
                  ? requests
                  : requests
                        .where(
                          (r) => r.status.toLowerCase() == tab.toLowerCase(),
                        )
                        .toList();
              if (filtered.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.build_outlined,
                  title: 'No $tab Requests',
                );
              }
              return RefreshIndicator(
                onRefresh: () =>
                    ref.read(hallAdminMaintenanceProvider.notifier).fetch(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final req = filtered[i];
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
                                    req.issue,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                StatusBadge(status: req.status),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                PriorityBadge(priority: req.priority),
                                const SizedBox(width: 8),
                                Text(
                                  'Room ${req.roomNumber ?? req.roomId}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              req.issue,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'By: ${req.studentName ?? 'Student #${req.studentId}'} \u2022 ${req.submittedOn?.toString().split(' ')[0] ?? ''}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (req.technicianNote != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Tech Note: ${req.technicianNote}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            if (req.status != 'Resolved') ...[
                              const Divider(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (req.status == 'Pending')
                                    TextButton(
                                      onPressed: () => _updateStatus(
                                        req.requestId,
                                        'In Progress',
                                      ),
                                      child: const Text('Start'),
                                    ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () =>
                                        _updateWithNote(req.requestId),
                                    child: const Text('Update & Note'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.approved,
                                    ),
                                    onPressed: () => _updateStatus(
                                      req.requestId,
                                      'Resolved',
                                    ),
                                    child: const Text('Resolve'),
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
          message: 'Failed to load maintenance requests',
          onRetry: () =>
              ref.read(hallAdminMaintenanceProvider.notifier).fetch(),
        ),
      ),
    );
  }

  Future<void> _updateStatus(int id, String status) async {
    await ref.read(hallAdminMaintenanceProvider.notifier).updateStatus(id, {
      'status': status,
    });
  }

  Future<void> _updateWithNote(int id) async {
    final noteCtrl = TextEditingController();
    String? selectedStatus;
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Maintenance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Status'),
              items: [
                'Pending',
                'In Progress',
                'Resolved',
              ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => selectedStatus = v,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Technician Note',
                hintText: 'Add a note...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, {
              'status': selectedStatus ?? 'In Progress',
              'technicianNote': noteCtrl.text.trim(),
            }),
            child: const Text('Update'),
          ),
        ],
      ),
    );
    if (result != null) {
      await ref
          .read(hallAdminMaintenanceProvider.notifier)
          .updateStatus(id, result);
    }
  }
}
