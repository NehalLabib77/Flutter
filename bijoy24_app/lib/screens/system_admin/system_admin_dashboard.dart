import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../providers/system_admin_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/stat_card.dart';

class SystemAdminDashboardShell extends StatelessWidget {
  final Widget child;
  const SystemAdminDashboardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child);
  }
}

class SystemAdminHomeScreen extends ConsumerStatefulWidget {
  const SystemAdminHomeScreen({super.key});

  @override
  ConsumerState<SystemAdminHomeScreen> createState() =>
      _SystemAdminHomeScreenState();
}

class _SystemAdminHomeScreenState extends ConsumerState<SystemAdminHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(sysAdminDashboardProvider.notifier).fetch();
      ref.read(sysAdminHallAdminsProvider.notifier).fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sysAdminDashboardProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            sliver: state.when(
              data: (stats) => SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
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
                    color: AppColors.info,
                  ),
                  StatCard(
                    icon: Icons.people_rounded,
                    label: 'Total Students',
                    value: '${stats.totalStudents}',
                    color: AppColors.approved,
                  ),
                  StatCard(
                    icon: Icons.admin_panel_settings_rounded,
                    label: 'Total Admins',
                    value: '${stats.totalAdmins}',
                    color: AppColors.reserved,
                  ),
                  StatCard(
                    icon: Icons.how_to_reg_rounded,
                    label: 'Boarder Entries',
                    value: '${stats.totalBoarderEntries}',
                    color: AppColors.pending,
                  ),
                  StatCard(
                    icon: Icons.pending_actions_rounded,
                    label: 'Pending Apps',
                    value: '${stats.pendingApplications}',
                    color: AppColors.warning,
                  ),
                ],
              ),
              loading: () => const SliverToBoxAdapter(
                child: SizedBox(height: 200, child: LoadingWidget()),
              ),
              error: (_, _) => SliverToBoxAdapter(
                child: ErrorRetryWidget(
                  message: 'Failed to load dashboard',
                  onRetry: () =>
                      ref.read(sysAdminDashboardProvider.notifier).fetch(),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Management',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  _ManagementGrid(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white24,
              child: Icon(Icons.shield_rounded, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'System Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'BIJOY-24 Hall Management',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => context.push('/system-admin/settings'),
              icon: const Icon(Icons.settings_rounded, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagementGrid extends StatelessWidget {
  final _items = const [
    _MI(
      Icons.apartment_rounded,
      'Halls',
      '/system-admin/halls',
      AppColors.primary,
    ),
    _MI(
      Icons.admin_panel_settings_rounded,
      'Admins',
      '/system-admin/admins',
      AppColors.info,
    ),
    _MI(
      Icons.how_to_reg_rounded,
      'Registry',
      '/system-admin/registry',
      AppColors.approved,
    ),
    _MI(
      Icons.meeting_room_rounded,
      'Global Rooms',
      '/system-admin/global-rooms',
      AppColors.pending,
    ),
    _MI(
      Icons.analytics_rounded,
      'Statistics',
      '/system-admin/database-stats',
      AppColors.reserved,
    ),
    _MI(
      Icons.settings_rounded,
      'Settings',
      '/system-admin/settings',
      AppColors.warning,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _items.length,
      itemBuilder: (ctx, i) {
        final item = _items[i];
        return AppCard(
          onTap: () => context.push(item.route),
          padding: const EdgeInsets.all(12),
          margin: EdgeInsets.zero,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 22),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MI {
  final IconData icon;
  final String label;
  final String route;
  final Color color;
  const _MI(this.icon, this.label, this.route, this.color);
}
