import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/stat_card.dart';

class HallAdminDashboardShell extends ConsumerStatefulWidget {
  final Widget child;
  const HallAdminDashboardShell({super.key, required this.child});

  @override
  ConsumerState<HallAdminDashboardShell> createState() =>
      _HallAdminDashboardShellState();
}

class _HallAdminDashboardShellState
    extends ConsumerState<HallAdminDashboardShell> {
  int _currentIndex = 0;

  final _tabs = const [
    '/hall-admin',
    '/hall-admin/room-applications',
    '/hall-admin/rooms',
    '/hall-admin/maintenance',
  ];

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          context.go(_tabs[i]);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Applications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room),
            label: 'Rooms',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Maintenance',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 28,
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    auth.user?.name ?? 'Hall Admin',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Hall Admin',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                context.go('/hall-admin');
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Room Applications'),
              onTap: () {
                Navigator.pop(context);
                context.go('/hall-admin/room-applications');
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_seat),
              title: const Text('Seat Applications'),
              onTap: () {
                Navigator.pop(context);
                context.push('/hall-admin/seat-applications');
              },
            ),
            ListTile(
              leading: const Icon(Icons.meeting_room),
              title: const Text('Manage Rooms'),
              onTap: () {
                Navigator.pop(context);
                context.go('/hall-admin/rooms');
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment_ind),
              title: const Text('Room Assignments'),
              onTap: () {
                Navigator.pop(context);
                context.push('/hall-admin/assignments');
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Room Change Requests'),
              onTap: () {
                Navigator.pop(context);
                context.push('/hall-admin/room-changes');
              },
            ),
            ListTile(
              leading: const Icon(Icons.build),
              title: const Text('Maintenance'),
              onTap: () {
                Navigator.pop(context);
                context.go('/hall-admin/maintenance');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Room Members'),
              onTap: () {
                Navigator.pop(context);
                context.push('/hall-admin/room-members');
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

class HallAdminHomeScreen extends ConsumerWidget {
  const HallAdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${auth.user?.name ?? 'Admin'}!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Hall Administration Dashboard',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  StatCard(
                    title: 'Total Rooms',
                    value: '--',
                    icon: Icons.meeting_room,
                    color: AppColors.primary,
                    onTap: () => context.go('/hall-admin/rooms'),
                  ),
                  StatCard(
                    title: 'Assigned Rooms',
                    value: '--',
                    icon: Icons.check_circle,
                    color: AppColors.approved,
                    onTap: () => context.push('/hall-admin/assignments'),
                  ),
                  StatCard(
                    title: 'Active Students',
                    value: '--',
                    icon: Icons.people,
                    color: AppColors.info,
                  ),
                  StatCard(
                    title: 'Pending Applications',
                    value: '--',
                    icon: Icons.pending_actions,
                    color: AppColors.pending,
                    onTap: () => context.go('/hall-admin/room-applications'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _ActionTile(
                icon: Icons.assignment,
                label: 'View Room Applications',
                color: AppColors.pending,
                onTap: () => context.go('/hall-admin/room-applications'),
              ),
              _ActionTile(
                icon: Icons.event_seat,
                label: 'View Seat Applications',
                color: AppColors.info,
                onTap: () => context.push('/hall-admin/seat-applications'),
              ),
              _ActionTile(
                icon: Icons.add_home,
                label: 'Create Room',
                color: AppColors.approved,
                onTap: () => context.push('/hall-admin/rooms/create'),
              ),
              _ActionTile(
                icon: Icons.build,
                label: 'Manage Maintenance',
                color: AppColors.warning,
                onTap: () => context.go('/hall-admin/maintenance'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(fontWeight: FontWeight.w600, color: color),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: color.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
