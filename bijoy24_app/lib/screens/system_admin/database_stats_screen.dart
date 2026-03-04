import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../providers/system_admin_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/loading_widget.dart';

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
      appBar: AppBar(title: const Text('Database Statistics')),
      body: state.when(
        data: (stats) {
          return RefreshIndicator(
            onRefresh: () => ref.read(adminStatsProvider.notifier).fetch(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Entity Counts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    StatCard(
                      title: 'Halls',
                      value: '${stats.totalHalls}',
                      icon: Icons.apartment,
                      color: AppColors.primary,
                    ),
                    StatCard(
                      title: 'Rooms',
                      value: '${stats.totalRooms}',
                      icon: Icons.meeting_room,
                      color: AppColors.accent,
                    ),
                    StatCard(
                      title: 'Students',
                      value: '${stats.totalStudents}',
                      icon: Icons.people,
                      color: AppColors.info,
                    ),
                    StatCard(
                      title: 'Hall Admins',
                      value: '${stats.totalAdmins}',
                      icon: Icons.admin_panel_settings,
                      color: Colors.deepPurple,
                    ),
                    StatCard(
                      title: 'Boarders',
                      value: '${stats.totalBoarderEntries}',
                      icon: Icons.badge,
                      color: Colors.brown,
                    ),
                    StatCard(
                      title: 'Assigned Rooms',
                      value: '${stats.assignedRooms}',
                      icon: Icons.assignment,
                      color: AppColors.approved,
                    ),
                    StatCard(
                      title: 'Pending Apps',
                      value: '${stats.pendingApplications}',
                      icon: Icons.description,
                      color: AppColors.warning,
                    ),
                    StatCard(
                      title: 'Maintenance',
                      value: '${stats.pendingMaintenance}',
                      icon: Icons.build,
                      color: AppColors.error,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (_, __) => ErrorRetryWidget(
          message: 'Failed to load statistics',
          onRetry: () => ref.read(adminStatsProvider.notifier).fetch(),
        ),
      ),
    );
  }
}
