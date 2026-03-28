import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
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
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) async {
          if (i == 3) {
            // Logout
            await ref.read(authProvider.notifier).logout();
            await Future.delayed(const Duration(milliseconds: 100));
            if (mounted) {
              context.go('/login');
            }
          } else {
            setState(() => _currentIndex = i);
            context.go(_tabs[i]);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.meeting_room_outlined),
            selectedIcon: Icon(Icons.meeting_room_rounded),
            label: 'Room',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon: Icon(Icons.build_rounded),
            label: 'Maintenance',
          ),
          NavigationDestination(
            icon: Icon(Icons.logout_outlined),
            selectedIcon: Icon(Icons.logout_rounded),
            label: 'Logout',
          ),
        ],
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
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(auth, ref, context)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                StatCard(
                  label: 'Room Status',
                  value: '--',
                  icon: Icons.meeting_room_rounded,
                  color: AppColors.info,
                  onTap: () => context.push('/student/roommates'),
                ),
                StatCard(
                  label: 'Seat Status',
                  value: '--',
                  icon: Icons.event_seat_rounded,
                  color: AppColors.accent,
                  onTap: () => context.push('/student/seat-booking'),
                ),
                StatCard(
                  label: 'Maintenance',
                  value: '0',
                  icon: Icons.build_rounded,
                  color: AppColors.pending,
                  onTap: () => context.go('/student/maintenance'),
                ),
                StatCard(
                  label: 'Room Change',
                  value: '--',
                  icon: Icons.swap_horiz_rounded,
                  color: AppColors.primary,
                  onTap: () => context.push('/student/room-change'),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionButton(
                    icon: Icons.add_home_rounded,
                    label: 'Apply for Room',
                    color: AppColors.primary,
                    onTap: () => context.go('/student/apply-room'),
                  ),
                  _QuickActionButton(
                    icon: Icons.event_seat_rounded,
                    label: 'Book a Seat',
                    color: AppColors.info,
                    onTap: () => context.push('/student/seat-booking'),
                  ),
                  _QuickActionButton(
                    icon: Icons.report_problem_rounded,
                    label: 'Report Issue',
                    color: AppColors.warning,
                    onTap: () => context.push('/student/submit-maintenance'),
                  ),
                  _QuickActionButton(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Request Room Change',
                    color: AppColors.approved,
                    onTap: () => context.push('/student/room-change'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AuthState auth, WidgetRef ref, BuildContext context) {
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
              child: Icon(Icons.school_rounded, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, ${auth.user?.name ?? 'Student'}!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Here\'s your hall overview',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Logout',
            ),
          ],
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
