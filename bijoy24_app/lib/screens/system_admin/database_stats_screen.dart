import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../providers/system_admin_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/stat_card.dart';

class DatabaseStatsScreen extends ConsumerStatefulWidget {
  const DatabaseStatsScreen({super.key});

  @override
  ConsumerState<DatabaseStatsScreen> createState() =>
      _DatabaseStatsScreenState();
}

class _DatabaseStatsScreenState extends ConsumerState<DatabaseStatsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminStatsProvider.notifier).fetch());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminStatsProvider);

    return Scaffold(
      appBar: const GradientAppBar(title: 'Database Stats'),
      body: state.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorRetryWidget(
          message: 'Failed to load stats',
          onRetry: () => ref.read(adminStatsProvider.notifier).fetch(),
        ),
        data: (stats) => RefreshIndicator(
          onRefresh: () => ref.read(adminStatsProvider.notifier).fetch(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.storage_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'System Overview',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Real-time database statistics',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Stats grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  StatCard(
                    icon: Icons.apartment_rounded,
                    label: 'Total Halls',
                    value: '${stats.totalHalls}',
                    color: AppColors.primary,
                  ),
                  StatCard(
                    icon: Icons.meeting_room_rounded,
                    label: 'Total Rooms',
                    value: '${stats.totalRooms}',
                    color: Colors.teal,
                  ),
                  StatCard(
                    icon: Icons.people_rounded,
                    label: 'Students',
                    value: '${stats.totalStudents}',
                    color: Colors.indigo,
                  ),
                  StatCard(
                    icon: Icons.admin_panel_settings_rounded,
                    label: 'Admins',
                    value: '${stats.totalAdmins}',
                    color: Colors.deepPurple,
                  ),
                  StatCard(
                    icon: Icons.how_to_reg_rounded,
                    label: 'Boarder Entries',
                    value: '${stats.totalBoarderEntries}',
                    color: Colors.brown,
                  ),
                  StatCard(
                    icon: Icons.check_circle_rounded,
                    label: 'Assigned Rooms',
                    value: '${stats.assignedRooms}',
                    color: Colors.green,
                  ),
                  StatCard(
                    icon: Icons.pending_actions_rounded,
                    label: 'Pending Apps',
                    value: '${stats.pendingApplications}',
                    color: Colors.orange,
                  ),
                  StatCard(
                    icon: Icons.build_circle_rounded,
                    label: 'Pending Maint.',
                    value: '${stats.pendingMaintenance}',
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
