import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student.dart';
import '../models/room_assignment.dart';
import '../models/room_application.dart';
import '../models/seat_application.dart';
import '../models/room_change_request.dart';
import '../models/maintenance_request.dart';
import '../services/api_service.dart';

class StudentProfileNotifier extends StateNotifier<AsyncValue<Student?>> {
  final ApiService _api = ApiService();

  StudentProfileNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getStudentProfile();
      state = AsyncValue.data(Student.fromJson(response.data));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> update(Map<String, dynamic> data) async {
    try {
      await _api.updateStudentProfile(data);
      await fetch();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final studentProfileProvider =
    StateNotifierProvider<StudentProfileNotifier, AsyncValue<Student?>>((ref) {
      return StudentProfileNotifier();
    });

class RoomAssignmentNotifier
    extends StateNotifier<AsyncValue<RoomAssignment?>> {
  final ApiService _api = ApiService();

  RoomAssignmentNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getRoomAssignment();
      if (response.data != null) {
        state = AsyncValue.data(RoomAssignment.fromJson(response.data));
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final roomAssignmentProvider =
    StateNotifierProvider<RoomAssignmentNotifier, AsyncValue<RoomAssignment?>>((
      ref,
    ) {
      return RoomAssignmentNotifier();
    });

class RoomApplicationNotifier
    extends StateNotifier<AsyncValue<RoomApplication?>> {
  final ApiService _api = ApiService();

  RoomApplicationNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getRoomApplicationStatus();
      if (response.data != null) {
        state = AsyncValue.data(RoomApplication.fromJson(response.data));
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> submit(Map<String, dynamic> data) async {
    try {
      await _api.submitRoomApplication(data);
      await fetch();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final roomApplicationProvider =
    StateNotifierProvider<
      RoomApplicationNotifier,
      AsyncValue<RoomApplication?>
    >((ref) {
      return RoomApplicationNotifier();
    });

class SeatApplicationNotifier
    extends StateNotifier<AsyncValue<SeatApplication?>> {
  final ApiService _api = ApiService();

  SeatApplicationNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getSeatApplicationStatus();
      if (response.data != null) {
        state = AsyncValue.data(SeatApplication.fromJson(response.data));
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> submit(Map<String, dynamic> data) async {
    try {
      await _api.submitSeatApplication(data);
      await fetch();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final seatApplicationProvider =
    StateNotifierProvider<
      SeatApplicationNotifier,
      AsyncValue<SeatApplication?>
    >((ref) {
      return SeatApplicationNotifier();
    });

class RoommatesNotifier extends StateNotifier<AsyncValue<List<Student>>> {
  final ApiService _api = ApiService();

  RoommatesNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getRoommates();
      final list = (response.data as List)
          .map((e) => Student.fromJson(e))
          .toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final roommatesProvider =
    StateNotifierProvider<RoommatesNotifier, AsyncValue<List<Student>>>((ref) {
      return RoommatesNotifier();
    });

class RoomChangeNotifier
    extends StateNotifier<AsyncValue<List<RoomChangeRequest>>> {
  final ApiService _api = ApiService();

  RoomChangeNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getRoomChangeHistory();
      final list = (response.data as List)
          .map((e) => RoomChangeRequest.fromJson(e))
          .toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> submit(Map<String, dynamic> data) async {
    try {
      await _api.submitRoomChangeRequest(data);
      await fetch();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final roomChangeProvider =
    StateNotifierProvider<
      RoomChangeNotifier,
      AsyncValue<List<RoomChangeRequest>>
    >((ref) {
      return RoomChangeNotifier();
    });

class MaintenanceNotifier
    extends StateNotifier<AsyncValue<List<MaintenanceRequest>>> {
  final ApiService _api = ApiService();

  MaintenanceNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getStudentMaintenance();
      final list = (response.data as List)
          .map((e) => MaintenanceRequest.fromJson(e))
          .toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> submit(Map<String, dynamic> data) async {
    try {
      await _api.submitMaintenanceRequest(data);
      await fetch();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final studentMaintenanceProvider =
    StateNotifierProvider<
      MaintenanceNotifier,
      AsyncValue<List<MaintenanceRequest>>
    >((ref) {
      return MaintenanceNotifier();
    });
