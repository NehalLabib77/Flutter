import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hall.dart';
import '../models/hall_admin.dart';
import '../models/boarder_registry.dart';
import '../models/user.dart';
import '../services/api_service.dart';

// System Admin Dashboard
class SysAdminDashboardNotifier
    extends StateNotifier<AsyncValue<DashboardStats>> {
  final ApiService _api = ApiService();

  SysAdminDashboardNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getAdminDashboard();
      state = AsyncValue.data(DashboardStats.fromJson(response.data));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final sysAdminDashboardProvider =
    StateNotifierProvider<
      SysAdminDashboardNotifier,
      AsyncValue<DashboardStats>
    >((ref) {
      return SysAdminDashboardNotifier();
    });

// Halls
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
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

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

// Hall Admins
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
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

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

// Boarder Registry
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
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

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

// Admin Stats
class AdminStatsNotifier extends StateNotifier<AsyncValue<DashboardStats>> {
  final ApiService _api = ApiService();

  AdminStatsNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getAdminStats();
      state = AsyncValue.data(DashboardStats.fromJson(response.data));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final adminStatsProvider =
    StateNotifierProvider<AdminStatsNotifier, AsyncValue<DashboardStats>>((
      ref,
    ) {
      return AdminStatsNotifier();
    });
