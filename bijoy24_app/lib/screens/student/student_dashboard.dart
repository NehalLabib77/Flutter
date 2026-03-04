import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/stat_card.dart';

class StudentDashboard extends ConsumerStatefulWidget {
  final Widget child;
  const StudentDashboard({super.key, required this.child});

  @override
  ConsumerState<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends ConsumerState<StudentDashboard> {
  int _currentIndex = 0;

  final _tabs = const [
    '/student',
    '/student/apply-room',
    '/student/maintenance',
    '/student/profile',
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room),
            label: 'Room',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Maintenance',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
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
                      Icons.person,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    auth.user?.name ?? 'Student',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Student',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                context.go('/student');
              },
            ),
            ListTile(
              leading: const Icon(Icons.meeting_room),
              title: const Text('Apply for Room'),
              onTap: () {
                Navigator.pop(context);
                context.go('/student/apply-room');
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_seat),
              title: const Text('Seat Booking'),
              onTap: () {
                Navigator.pop(context);
                context.push('/student/seat-booking');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('My Roommates'),
              onTap: () {
                Navigator.pop(context);
                context.push('/student/roommates');
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Room Change'),
              onTap: () {
                Navigator.pop(context);
                context.push('/student/room-change');
              },
            ),
            ListTile(
              leading: const Icon(Icons.build),
              title: const Text('Maintenance'),
              onTap: () {
                Navigator.pop(context);
                context.go('/student/maintenance');
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

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

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
              // Welcome
              Text(
                'Welcome, ${auth.user?.name ?? 'Student'}!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Here\'s your hall overview',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              // Stat cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  StatCard(
                    title: 'Room Status',
                    value: '--',
                    icon: Icons.meeting_room,
                    color: AppColors.info,
                    onTap: () => context.push('/student/roommates'),
                  ),
                  StatCard(
                    title: 'Seat Status',
                    value: '--',
                    icon: Icons.event_seat,
                    color: AppColors.accent,
                    onTap: () => context.push('/student/seat-booking'),
                  ),
                  StatCard(
                    title: 'Maintenance',
                    value: '0',
                    icon: Icons.build,
                    color: AppColors.pending,
                    onTap: () => context.go('/student/maintenance'),
                  ),
                  StatCard(
                    title: 'Room Change',
                    value: '--',
                    icon: Icons.swap_horiz,
                    color: AppColors.primary,
                    onTap: () => context.push('/student/room-change'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _QuickActionButton(
                icon: Icons.add_home,
                label: 'Apply for Room',
                color: AppColors.primary,
                onTap: () => context.go('/student/apply-room'),
              ),
              _QuickActionButton(
                icon: Icons.event_seat,
                label: 'Book a Seat',
                color: AppColors.info,
                onTap: () => context.push('/student/seat-booking'),
              ),
              _QuickActionButton(
                icon: Icons.report_problem,
                label: 'Report Issue',
                color: AppColors.warning,
                onTap: () => context.push('/student/submit-maintenance'),
              ),
              _QuickActionButton(
                icon: Icons.swap_horiz,
                label: 'Request Room Change',
                color: AppColors.approved,
                onTap: () => context.push('/student/room-change'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
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
