import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hall.dart';
import '../models/hall_admin.dart';
import '../models/boarder_registry.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class SysAdminDashboardNotifier
    extends StateNotifier<AsyncValue<DashboardStats>> {
  final ApiService _api = ApiService();

  SysAdminDashboardNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getAdminDashboard();
      state = AsyncValue.data(DashboardStats.fromJson(response.data));
    } catch (_) {
      state = AsyncValue.data(_mockStats());
    }
  }

  DashboardStats _mockStats() => DashboardStats(
    totalHalls: 4,
    totalRooms: 48,
    totalStudents: 320,
    totalAdmins: 4,
    totalBoarderEntries: 298,
    assignedRooms: 40,
    pendingApplications: 12,
    pendingMaintenance: 5,
  );
}

final sysAdminDashboardProvider =
    StateNotifierProvider<
      SysAdminDashboardNotifier,
      AsyncValue<DashboardStats>
    >((ref) {
      return SysAdminDashboardNotifier();
    });

class SysAdminHallsNotifier extends StateNotifier<AsyncValue<List<Hall>>> {
  final ApiService _api = ApiService();

  SysAdminHallsNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getAdminHalls();
      final list = (response.data as List)
          .map((e) => Hall.fromJson(e))
          .toList();
      state = AsyncValue.data(list);
    } catch (_) {
      state = AsyncValue.data(_mockHalls());
    }
  }

  List<Hall> _mockHalls() => [
    Hall(
      hallId: 1,
      hallName: 'Jinnah Hall',
      hallType: 'Male',
      hallCapacity: 120,
      location: 'North Campus',
    ),
    Hall(
      hallId: 2,
      hallName: 'Kazi Nazrul Hall',
      hallType: 'Male',
      hallCapacity: 100,
      location: 'East Campus',
    ),
    Hall(
      hallId: 3,
      hallName: 'Begum Rokeya Hall',
      hallType: 'Female',
      hallCapacity: 80,
      location: 'West Campus',
    ),
    Hall(
      hallId: 4,
      hallName: 'Shaheed Hall',
      hallType: 'Male',
      hallCapacity: 90,
      location: 'South Campus',
    ),
  ];

  Future<bool> create(Map<String, dynamic> data) async {
    try {
      await _api.createHall(data);
      await fetch();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> update(int id, Map<String, dynamic> data) async {
    try {
      await _api.updateHall(id, data);
      await fetch();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _api.deleteHall(id);
      await fetch();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final sysAdminHallsProvider =
    StateNotifierProvider<SysAdminHallsNotifier, AsyncValue<List<Hall>>>((ref) {
      return SysAdminHallsNotifier();
    });

class SysAdminHallAdminsNotifier
    extends StateNotifier<AsyncValue<List<HallAdmin>>> {
  final ApiService _api = ApiService();

  SysAdminHallAdminsNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getAdminHallAdmins();
      final list = (response.data as List)
          .map((e) => HallAdmin.fromJson(e))
          .toList();
      state = AsyncValue.data(list);
    } catch (_) {
      state = AsyncValue.data(_mockHallAdmins());
    }
  }

  List<HallAdmin> _mockHallAdmins() => [
    HallAdmin(
      hallAdminId: 1,
      hallId: 1,
      adminName: 'Dr. Rahim Uddin',
      email: 'rahim@bubt.edu.bd',
      phone: '01711000001',
      status: 'Active',
      hallName: 'Jinnah Hall',
      isRegistered: true,
    ),
    HallAdmin(
      hallAdminId: 2,
      hallId: 2,
      adminName: 'Prof. Karim Ahmed',
      email: 'karim@bubt.edu.bd',
      phone: '01711000002',
      status: 'Active',
      hallName: 'Kazi Nazrul Hall',
      isRegistered: true,
    ),
    HallAdmin(
      hallAdminId: 3,
      hallId: 3,
      adminName: 'Ms. Fatema Begum',
      email: 'fatema@bubt.edu.bd',
      phone: '01711000003',
      status: 'Active',
      hallName: 'Begum Rokeya Hall',
      isRegistered: true,
    ),
    HallAdmin(
      hallAdminId: 4,
      hallId: 4,
      adminName: 'Mr. Hasan Ali',
      email: 'hasan@bubt.edu.bd',
      phone: '01711000004',
      status: 'Inactive',
      hallName: 'Shaheed Hall',
      isRegistered: false,
    ),
  ];

  Future<Map<String, dynamic>?> create(Map<String, dynamic> data) async {
    try {
      final response = await _api.createHallAdmin(data);
      await fetch();
      return response.data;
    } catch (_) {
      return null;
    }
  }

  Future<bool> update(int id, Map<String, dynamic> data) async {
    try {
      await _api.updateHallAdmin(id, data);
      await fetch();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _api.deleteHallAdmin(id);
      await fetch();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final sysAdminHallAdminsProvider =
    StateNotifierProvider<
      SysAdminHallAdminsNotifier,
      AsyncValue<List<HallAdmin>>
    >((ref) {
      return SysAdminHallAdminsNotifier();
    });

class BoarderRegistryNotifier
    extends StateNotifier<AsyncValue<List<BoarderRegistry>>> {
  final ApiService _api = ApiService();

  BoarderRegistryNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getBoarderRegistry();
      final list = (response.data as List)
          .map((e) => BoarderRegistry.fromJson(e))
          .toList();
      state = AsyncValue.data(list);
    } catch (_) {
      state = AsyncValue.data(_mockRegistry());
    }
  }

  List<BoarderRegistry> _mockRegistry() => [
    BoarderRegistry(
      registryId: 1,
      boarderNo: 'B-2024-001',
      studentName: 'Ahsan Habib',
      studentId: 'STU-001',
      status: 'Active',
      hallId: 1,
      hallName: 'Jinnah Hall',
      roomNumber: 'A-101',
      department: 'CSE',
      session: '2021-22',
    ),
    BoarderRegistry(
      registryId: 2,
      boarderNo: 'B-2024-002',
      studentName: 'Rafiq Islam',
      studentId: 'STU-002',
      status: 'Active',
      hallId: 1,
      hallName: 'Jinnah Hall',
      roomNumber: 'A-102',
      department: 'EEE',
      session: '2022-23',
    ),
    BoarderRegistry(
      registryId: 3,
      boarderNo: 'B-2024-003',
      studentName: 'Sumaiya Khatun',
      studentId: 'STU-003',
      status: 'Active',
      hallId: 3,
      hallName: 'Begum Rokeya Hall',
      roomNumber: 'C-201',
      department: 'BBA',
      session: '2021-22',
    ),
    BoarderRegistry(
      registryId: 4,
      boarderNo: 'B-2024-004',
      studentName: 'Noman Khan',
      studentId: 'STU-004',
      status: 'Inactive',
      hallId: 2,
      hallName: 'Kazi Nazrul Hall',
      roomNumber: 'B-105',
      department: 'Law',
      session: '2020-21',
    ),
    BoarderRegistry(
      registryId: 5,
      boarderNo: 'B-2024-005',
      studentName: 'Tasnim Akter',
      studentId: 'STU-005',
      status: 'Active',
      hallId: 3,
      hallName: 'Begum Rokeya Hall',
      roomNumber: 'C-203',
      department: 'CSE',
      session: '2023-24',
    ),
  ];

  Future<bool> create(Map<String, dynamic> data) async {
    try {
      await _api.createBoarderEntry(data);
      await fetch();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> update(int id, Map<String, dynamic> data) async {
    try {
      await _api.updateBoarderEntry(id.toString(), data);
      await fetch();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _api.deleteBoarderEntry(id.toString());
      await fetch();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final boarderRegistryProvider =
    StateNotifierProvider<
      BoarderRegistryNotifier,
      AsyncValue<List<BoarderRegistry>>
    >((ref) {
      return BoarderRegistryNotifier();
    });

class AdminStatsNotifier extends StateNotifier<AsyncValue<DashboardStats>> {
  final ApiService _api = ApiService();

  AdminStatsNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getAdminStats();
      state = AsyncValue.data(DashboardStats.fromJson(response.data));
    } catch (_) {
      state = AsyncValue.data(
        DashboardStats(
          totalHalls: 4,
          totalRooms: 48,
          totalStudents: 320,
          totalAdmins: 4,
          totalBoarderEntries: 298,
          assignedRooms: 40,
          pendingApplications: 12,
          pendingMaintenance: 5,
        ),
      );
    }
  }
}

final adminStatsProvider =
    StateNotifierProvider<AdminStatsNotifier, AsyncValue<DashboardStats>>((
      ref,
    ) {
      return AdminStatsNotifier();
    });
