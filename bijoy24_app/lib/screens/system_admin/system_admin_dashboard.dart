import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/system_admin_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/loading_widget.dart';

class SystemAdminDashboardShell extends ConsumerWidget {
  final Widget child;
  const SystemAdminDashboardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();

    int currentIndex = 0;
    if (location.contains('/halls')) currentIndex = 1;
    if (location.contains('/admins')) currentIndex = 2;
    if (location.contains('/registry')) currentIndex = 3;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/system-admin');
              break;
            case 1:
              context.go('/system-admin/halls');
              break;
            case 2:
              context.go('/system-admin/admins');
              break;
            case 3:
              context.go('/system-admin/registry');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.apartment_outlined),
            selectedIcon: Icon(Icons.apartment),
            label: 'Halls',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: 'Admins',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: 'Registry',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.shield_outlined,
                      size: 28,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'System Administrator',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'BIJOY-24',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.storage),
              title: const Text('Database Stats'),
              onTap: () {
                Navigator.pop(context);
                context.push('/system-admin/database-stats');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('System Settings'),
              onTap: () {
                Navigator.pop(context);
                context.push('/system-admin/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.meeting_room_outlined),
              title: const Text('Global Rooms'),
              onTap: () {
                Navigator.pop(context);
                context.push('/system-admin/global-rooms');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text(
                'Logout',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
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
    Future.microtask(
      () => ref.read(sysAdminDashboardProvider.notifier).fetch(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sysAdminDashboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('System Admin'), centerTitle: true),
      body: state.when(
        data: (stats) {
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(sysAdminDashboardProvider.notifier).fetch(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Overview',
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
                      title: 'Total Halls',
                      value: '${stats.totalHalls}',
                      icon: Icons.apartment,
                      color: AppColors.primary,
                    ),
                    StatCard(
                      title: 'Total Rooms',
                      value: '${stats.totalRooms}',
                      icon: Icons.meeting_room,
                      color: AppColors.accent,
                    ),
                    StatCard(
                      title: 'Total Students',
                      value: '${stats.totalStudents}',
                      icon: Icons.people,
                      color: AppColors.approved,
                    ),
                    StatCard(
                      title: 'Hall Admins',
                      value: '${stats.totalAdmins}',
                      icon: Icons.admin_panel_settings,
                      color: AppColors.info,
                    ),
                    StatCard(
                      title: 'Active Boarders',
                      value: '${stats.totalBoarderEntries}',
                      icon: Icons.badge,
                      color: Colors.teal,
                    ),
                    StatCard(
                      title: 'Pending Issues',
                      value: '${stats.pendingMaintenance}',
                      icon: Icons.warning_amber,
                      color: AppColors.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _actionTile(
                  context,
                  Icons.add_business,
                  'Create Hall',
                  '/system-admin/halls/create',
                ),
                _actionTile(
                  context,
                  Icons.person_add,
                  'Register Hall Admin',
                  '/system-admin/admins/create',
                ),
                _actionTile(
                  context,
                  Icons.person_add_alt,
                  'Register Boarder',
                  '/system-admin/registry/create',
                ),
                _actionTile(
                  context,
                  Icons.storage,
                  'Database Statistics',
                  '/system-admin/database-stats',
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (_, __) => ErrorRetryWidget(
          message: 'Failed to load dashboard',
          onRetry: () => ref.read(sysAdminDashboardProvider.notifier).fetch(),
        ),
      ),
    );
  }

  Widget _actionTile(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(route),
      ),
    );
  }
}
