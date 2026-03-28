import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hall_admin_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/stat_card.dart';

class HallAdminDashboardShell extends ConsumerWidget {
  final Widget child;
  const HallAdminDashboardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
    );
  }
}

class HallAdminHomeScreen extends ConsumerStatefulWidget {
  const HallAdminHomeScreen({super.key});

  @override
  ConsumerState<HallAdminHomeScreen> createState() =>
      _HallAdminHomeScreenState();
}

class _HallAdminHomeScreenState extends ConsumerState<HallAdminHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(hallAdminDashboardProvider.notifier).fetch(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hallAdminDashboardProvider);
    final auth = ref.watch(authProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // gradient header
          SliverToBoxAdapter(child: _buildHeader(context, auth)),
          // stats grid
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
                    icon: Icons.meeting_room_rounded,
                    label: 'Total Rooms',
                    value: '${stats.totalRooms}',
                    color: AppColors.primary,
                  ),
                  StatCard(
                    icon: Icons.people_rounded,
                    label: 'Total Students',
                    value: '${stats.totalStudents}',
                    color: AppColors.info,
                  ),
                  StatCard(
                    icon: Icons.pending_actions_rounded,
                    label: 'Pending Apps',
                    value: '${stats.pendingApplications}',
                    color: AppColors.pending,
                  ),
                  StatCard(
                    icon: Icons.build_rounded,
                    label: 'Maintenance',
                    value: '${stats.pendingMaintenance}',
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
                      ref.read(hallAdminDashboardProvider.notifier).fetch(),
                ),
              ),
            ),
          ),
          // Quick actions
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionGrid(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthState auth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Builder(
                  builder: (ctx) => IconButton(
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                    icon: const Icon(Icons.menu, color: Colors.white),
                    tooltip: 'Open menu',
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, ${auth.user?.name ?? 'Hall Admin'}!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Hall Admin Panel',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    // Logout and clear auth state
                    await ref.read(authProvider.notifier).logout();
                    
                    // Give a small delay to ensure state is updated
                    await Future.delayed(const Duration(milliseconds: 100));
                    
                    // Navigate to login page
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                  ),
                  tooltip: 'Logout',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionGrid extends StatelessWidget {
  final _actions = const [
    _QA(
      Icons.meeting_room_rounded,
      'Rooms',
      '/hall-admin/rooms',
      AppColors.primary,
    ),
    _QA(
      Icons.assignment_rounded,
      'Applications',
      '/hall-admin/room-applications',
      AppColors.info,
    ),
    _QA(
      Icons.people_rounded,
      'Assignments',
      '/hall-admin/assignments',
      AppColors.approved,
    ),
    _QA(
      Icons.swap_horiz_rounded,
      'Room Changes',
      '/hall-admin/room-changes',
      AppColors.pending,
    ),
    _QA(
      Icons.build_circle_rounded,
      'Maintenance',
      '/hall-admin/maintenance',
      AppColors.warning,
    ),
    _QA(
      Icons.event_seat_rounded,
      'Seat Apps',
      '/hall-admin/seat-applications',
      AppColors.reserved,
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
      itemCount: _actions.length,
      itemBuilder: (ctx, i) {
        final a = _actions[i];
        return AppCard(
          onTap: () => context.push(a.route),
          padding: const EdgeInsets.all(12),
          margin: EdgeInsets.zero,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: a.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(a.icon, color: a.color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                a.label,
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

class _QA {
  final IconData icon;
  final String label;
  final String route;
  final Color color;
  const _QA(this.icon, this.label, this.route, this.color);
}
