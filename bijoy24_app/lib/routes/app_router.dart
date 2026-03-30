import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/student_registration_screen.dart';
import '../screens/auth/hall_admin_registration_screen.dart';

import '../screens/student/student_dashboard.dart';
import '../screens/student/apply_room_screen.dart';
import '../screens/student/seat_booking_screen.dart';
import '../screens/student/roommates_screen.dart';
import '../screens/student/room_change_screen.dart';
import '../screens/student/maintenance_list_screen.dart';
import '../screens/student/submit_maintenance_screen.dart';
import '../screens/student/student_profile_screen.dart';

import '../screens/hall_admin/hall_admin_dashboard.dart';
import '../screens/hall_admin/room_applications_screen.dart';
import '../screens/hall_admin/seat_applications_screen.dart';
import '../screens/hall_admin/manage_rooms_screen.dart';
import '../screens/hall_admin/create_room_screen.dart';
import '../screens/hall_admin/edit_room_screen.dart';
import '../screens/hall_admin/room_assignments_screen.dart';
import '../screens/hall_admin/room_change_requests_screen.dart';
import '../screens/hall_admin/maintenance_requests_screen.dart';
import '../screens/hall_admin/view_room_members_screen.dart';

import '../screens/system_admin/system_admin_dashboard.dart';
import '../screens/system_admin/manage_halls_screen.dart';
import '../screens/system_admin/create_hall_screen.dart';
import '../screens/system_admin/edit_hall_screen.dart';
import '../screens/system_admin/manage_hall_admins_screen.dart';
import '../screens/system_admin/create_hall_admin_screen.dart';
import '../screens/system_admin/edit_hall_admin_screen.dart';
import '../screens/system_admin/global_rooms_screen.dart';
import '../screens/system_admin/boarder_registry_screen.dart';
import '../screens/system_admin/create_boarder_screen.dart';
import '../screens/system_admin/edit_boarder_screen.dart';
import '../screens/system_admin/database_stats_screen.dart';
import '../screens/system_admin/system_settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _studentShellKey = GlobalKey<NavigatorState>();
final _hallAdminShellKey = GlobalKey<NavigatorState>();
final _sysAdminShellKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isAuth = authState.status == AuthStatus.authenticated;
      final isLoginRoute =
          state.uri.toString().startsWith('/login') ||
          state.uri.toString().startsWith('/register');

      if (!isAuth && !isLoginRoute) {
        return '/login';
      }

      if (isAuth && isLoginRoute) {
        final role = authState.user?.role;
        switch (role) {
          case 'Student':
            return '/student';
          case 'HallAdmin':
            return '/hall-admin';
          case 'SystemAdmin':
            return '/system-admin';
          default:
            return '/login';
        }
      }

      return null;
    },
    routes: [

      GoRoute(path: '/login', builder: (ctx, state) => const LoginScreen()),
      GoRoute(
        path: '/register/student',
        builder: (ctx, state) => const StudentRegistrationScreen(),
      ),
      GoRoute(
        path: '/register/hall-admin',
        builder: (ctx, state) => const HallAdminRegistrationScreen(),
      ),

      ShellRoute(
        navigatorKey: _studentShellKey,
        builder: (ctx, state, child) => StudentDashboard(child: child),
        routes: [
          GoRoute(
            path: '/student',
            builder: (ctx, state) => const StudentHomeScreen(),
            routes: [
              GoRoute(
                path: 'apply-room',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (ctx, state) => const ApplyRoomScreen(),
              ),
              GoRoute(
                path: 'seat-booking',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (ctx, state) => const SeatBookingScreen(),
              ),
              GoRoute(
                path: 'roommates',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (ctx, state) => const RoommatesScreen(),
              ),
              GoRoute(
                path: 'room-change',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (ctx, state) => const RoomChangeScreen(),
              ),
              GoRoute(
                path: 'maintenance',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (ctx, state) => const MaintenanceListScreen(),
              ),
              GoRoute(
                path: 'maintenance/submit',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (ctx, state) => const SubmitMaintenanceScreen(),
              ),
              GoRoute(
                path: 'profile',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (ctx, state) => const StudentProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      ShellRoute(
        navigatorKey: _hallAdminShellKey,
        builder: (ctx, state, child) => HallAdminDashboardShell(child: child),
        routes: [
          GoRoute(
            path: '/hall-admin',
            builder: (ctx, state) => const HallAdminHomeScreen(),
            routes: [
              GoRoute(
                path: 'room-applications',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (ctx, state) => const RoomApplicationsScreen(),
              ),
              GoRoute(
                path: 'seat-applications',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (ctx, state) => const SeatApplicationsScreen(),
              ),
              GoRoute(
                path: 'rooms',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (ctx, state) => const ManageRoomsScreen(),
              ),
              GoRoute(
                path: 'rooms/create',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (ctx, state) => const CreateRoomScreen(),
              ),
              GoRoute(
                path: 'rooms/edit/:id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (ctx, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return EditRoomScreen(roomId: id);
                },
              ),
              GoRoute(
                path: 'rooms/:id/members',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (ctx, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return ViewRoomMembersScreen(roomId: id);
                },
              ),
              GoRoute(
                path: 'assignments',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (ctx, state) => const RoomAssignmentsScreen(),
              ),
              GoRoute(
                path: 'room-changes',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (ctx, state) => const RoomChangeRequestsScreen(),
              ),
              GoRoute(
                path: 'maintenance',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (ctx, state) => const MaintenanceRequestsScreen(),
              ),
            ],
          ),
        ],
      ),

      ShellRoute(
        navigatorKey: _sysAdminShellKey,
        builder: (ctx, state, child) => SystemAdminDashboardShell(child: child),
        routes: [
          GoRoute(
            path: '/system-admin',
            builder: (ctx, state) => const SystemAdminHomeScreen(),
            routes: [
              GoRoute(
                path: 'halls',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (ctx, state) => const ManageHallsScreen(),
              ),
              GoRoute(
                path: 'halls/create',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (ctx, state) => const CreateHallScreen(),
              ),
              GoRoute(
                path: 'halls/edit/:id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (ctx, state) {
                  final id = int.parse(state.pathParameters['id'] ?? '0');
                  return EditHallScreen(hallId: id);
                },
              ),
              GoRoute(
                path: 'admins',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (ctx, state) => const ManageHallAdminsScreen(),
              ),
              GoRoute(
                path: 'admins/create',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (ctx, state) => const CreateHallAdminScreen(),
              ),
              GoRoute(
                path: 'admins/edit/:id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (ctx, state) {
                  final id = int.parse(state.pathParameters['id'] ?? '0');
                  return EditHallAdminScreen(adminId: id);
                },
              ),
              GoRoute(
                path: 'registry',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (ctx, state) => const BoarderRegistryScreen(),
              ),
              GoRoute(
                path: 'registry/create',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (ctx, state) => const CreateBoarderScreen(),
              ),
              GoRoute(
                path: 'registry/edit/:id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (ctx, state) {
                  final id = int.parse(state.pathParameters['id'] ?? '0');
                  return EditBoarderScreen(boarderId: id);
                },
              ),
              GoRoute(
                path: 'global-rooms',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (ctx, state) => const GlobalRoomsScreen(),
              ),
              GoRoute(
                path: 'database-stats',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (ctx, state) => const DatabaseStatsScreen(),
              ),
              GoRoute(
                path: 'settings',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (ctx, state) => const SystemSettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
