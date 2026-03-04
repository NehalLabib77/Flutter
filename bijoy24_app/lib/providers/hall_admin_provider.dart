import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/room.dart';
import '../models/room_application.dart';
import '../models/seat_application.dart';
import '../models/room_assignment.dart';
import '../models/room_change_request.dart';
import '../models/maintenance_request.dart';
import '../models/user.dart';
import '../services/api_service.dart';

// Hall Admin Dashboard
class HallAdminDashboardNotifier
    extends StateNotifier<AsyncValue<DashboardStats>> {
  final ApiService _api = ApiService();

  HallAdminDashboardNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getHallAdminDashboard();
      state = AsyncValue.data(DashboardStats.fromJson(response.data));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final hallAdminDashboardProvider =
    StateNotifierProvider<
      HallAdminDashboardNotifier,
      AsyncValue<DashboardStats>
    >((ref) {
      return HallAdminDashboardNotifier();
    });

// Room Applications
class HallAdminRoomAppsNotifier
    extends StateNotifier<AsyncValue<List<RoomApplication>>> {
  final ApiService _api = ApiService();

  HallAdminRoomAppsNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getHallAdminRoomApplications();
      final list = (response.data as List)
          .map((e) => RoomApplication.fromJson(e))
          .toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> approve(int id, Map<String, dynamic> data) async {
    try {
      await _api.approveRoomApplication(id, data);
      await fetch();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> reject(int id, Map<String, dynamic> data) async {
    try {
      await _api.rejectRoomApplication(id, data);
      await fetch();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final hallAdminRoomAppsProvider =
    StateNotifierProvider<
      HallAdminRoomAppsNotifier,
      AsyncValue<List<RoomApplication>>
    >((ref) {
      return HallAdminRoomAppsNotifier();
    });

// Seat Applications
class HallAdminSeatAppsNotifier
    extends StateNotifier<AsyncValue<List<SeatApplication>>> {
  final ApiService _api = ApiService();

  HallAdminSeatAppsNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getHallAdminSeatApplications();
      final list = (response.data as List)
          .map((e) => SeatApplication.fromJson(e))
          .toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> approve(int id, Map<String, dynamic> data) async {
    try {
      await _api.approveSeatApplication(id, data);
      await fetch();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> reject(int id, Map<String, dynamic> data) async {
    try {
      await _api.rejectSeatApplication(id, data);
      await fetch();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final hallAdminSeatAppsProvider =
    StateNotifierProvider<
      HallAdminSeatAppsNotifier,
      AsyncValue<List<SeatApplication>>
    >((ref) {
      return HallAdminSeatAppsNotifier();
    });

// Hall Admin Rooms
class HallAdminRoomsNotifier extends StateNotifier<AsyncValue<List<Room>>> {
  final ApiService _api = ApiService();

  HallAdminRoomsNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getHallAdminRooms();
      final list = (response.data as List)
          .map((e) => Room.fromJson(e))
          .toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> create(Map<String, dynamic> data) async {
    try {
      await _api.createRoom(data);
      await fetch();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> update(String id, Map<String, dynamic> data) async {
    try {
      await _api.updateRoom(id, data);
      await fetch();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _api.deleteRoom(id);
      await fetch();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final hallAdminRoomsProvider =
    StateNotifierProvider<HallAdminRoomsNotifier, AsyncValue<List<Room>>>((
      ref,
    ) {
      return HallAdminRoomsNotifier();
    });

// Room Assignments
class HallAdminAssignmentsNotifier
    extends StateNotifier<AsyncValue<List<RoomAssignment>>> {
  final ApiService _api = ApiService();

  HallAdminAssignmentsNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getHallAdminAssignments();
      final list = (response.data as List)
          .map((e) => RoomAssignment.fromJson(e))
          .toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> unassign(int id) async {
    try {
      await _api.unassignStudent(id);
      await fetch();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final hallAdminAssignmentsProvider =
    StateNotifierProvider<
      HallAdminAssignmentsNotifier,
      AsyncValue<List<RoomAssignment>>
    >((ref) {
      return HallAdminAssignmentsNotifier();
    });

// Room Change Requests
class HallAdminRoomChangeNotifier
    extends StateNotifier<AsyncValue<List<RoomChangeRequest>>> {
  final ApiService _api = ApiService();

  HallAdminRoomChangeNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getHallAdminRoomChangeRequests();
      final list = (response.data as List)
          .map((e) => RoomChangeRequest.fromJson(e))
          .toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> process(int id, Map<String, dynamic> data) async {
    try {
      await _api.processRoomChangeRequest(id, data);
      await fetch();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final hallAdminRoomChangeProvider =
    StateNotifierProvider<
      HallAdminRoomChangeNotifier,
      AsyncValue<List<RoomChangeRequest>>
    >((ref) {
      return HallAdminRoomChangeNotifier();
    });

// Hall Admin Maintenance
class HallAdminMaintenanceNotifier
    extends StateNotifier<AsyncValue<List<MaintenanceRequest>>> {
  final ApiService _api = ApiService();

  HallAdminMaintenanceNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getHallAdminMaintenance();
      final list = (response.data as List)
          .map((e) => MaintenanceRequest.fromJson(e))
          .toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> updateStatus(int id, Map<String, dynamic> data) async {
    try {
      await _api.updateMaintenanceStatus(id, data);
      await fetch();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final hallAdminMaintenanceProvider =
    StateNotifierProvider<
      HallAdminMaintenanceNotifier,
      AsyncValue<List<MaintenanceRequest>>
    >((ref) {
      return HallAdminMaintenanceNotifier();
    });
