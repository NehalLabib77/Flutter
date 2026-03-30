import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/room.dart';
import '../models/room_application.dart';
import '../models/seat_application.dart';
import '../models/room_assignment.dart';
import '../models/room_change_request.dart';
import '../models/maintenance_request.dart';
import '../models/user.dart';
import '../services/api_service.dart';

bool _isNetworkError(dynamic e) {
  if (e is DioException) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout;
  }
  return true;
}

DashboardStats _mockDashboardStats() => DashboardStats(
  totalHalls: 1,
  totalRooms: 24,
  totalStudents: 145,
  totalAdmins: 3,
  totalBoarderEntries: 138,
  assignedRooms: 18,
  pendingApplications: 8,
  pendingMaintenance: 3,
);

List<Room> _mockRoomList() => [
  Room(
    roomId: 'R001',
    hallId: 1,
    roomCapacity: 4,
    availableSlots: 2,
    roomNumber: '101',
    wing: 'A',
    block: '1',
    floor: 1,
    status: 'Available',
  ),
  Room(
    roomId: 'R002',
    hallId: 1,
    roomCapacity: 4,
    availableSlots: 0,
    roomNumber: '102',
    wing: 'A',
    block: '1',
    floor: 1,
    status: 'Full',
  ),
  Room(
    roomId: 'R003',
    hallId: 1,
    roomCapacity: 3,
    availableSlots: 1,
    roomNumber: '201',
    wing: 'B',
    block: '2',
    floor: 2,
    status: 'Available',
  ),
  Room(
    roomId: 'R004',
    hallId: 1,
    roomCapacity: 2,
    availableSlots: 0,
    roomNumber: '202',
    wing: 'B',
    block: '2',
    floor: 2,
    status: 'Full',
  ),
  Room(
    roomId: 'R005',
    hallId: 1,
    roomCapacity: 4,
    availableSlots: 4,
    roomNumber: '301',
    wing: 'C',
    block: '3',
    floor: 3,
    status: 'Available',
  ),
  Room(
    roomId: 'R006',
    hallId: 1,
    roomCapacity: 3,
    availableSlots: 0,
    roomNumber: '302',
    wing: 'C',
    block: '3',
    floor: 3,
    status: 'Maintenance',
  ),
];

List<RoomApplication> _mockRoomApps() => [
  RoomApplication(
    applicationId: 1,
    studentId: 'STU001',
    hallId: 1,
    status: 'Pending',
    applicationDate: DateTime.now().subtract(const Duration(days: 2)),
    studentName: 'Rakib Hasan',
    hallName: 'Zia Hall',
    faculty: 'CSE',
    semester: 5,
  ),
  RoomApplication(
    applicationId: 2,
    studentId: 'STU002',
    hallId: 1,
    status: 'Pending',
    applicationDate: DateTime.now().subtract(const Duration(days: 1)),
    studentName: 'Farhan Ahmed',
    hallName: 'Zia Hall',
    faculty: 'EEE',
    semester: 3,
  ),
  RoomApplication(
    applicationId: 3,
    studentId: 'STU003',
    hallId: 1,
    status: 'Approved',
    applicationDate: DateTime.now().subtract(const Duration(days: 5)),
    studentName: 'Mahfuz Alam',
    hallName: 'Zia Hall',
    faculty: 'ME',
    semester: 7,
  ),
  RoomApplication(
    applicationId: 4,
    studentId: 'STU004',
    hallId: 1,
    status: 'Pending',
    applicationDate: DateTime.now().subtract(const Duration(hours: 4)),
    studentName: 'Sabbir Islam',
    hallName: 'Zia Hall',
    faculty: 'CSE',
    semester: 1,
  ),
];

List<SeatApplication> _mockSeatApps() => [
  SeatApplication(
    applicationId: 1,
    studentId: 'STU005',
    seatId: 1,
    hallId: 1,
    roomId: 'R001',
    applicationDate: DateTime.now().subtract(const Duration(days: 1)),
    status: 'Pending',
    studentName: 'Mehedi Hasan',
    roomNumber: '101',
    seatType: 'Single',
    seatNumber: 3,
    academicYear: '2024-25',
    semester: '5th',
  ),
  SeatApplication(
    applicationId: 2,
    studentId: 'STU006',
    seatId: 2,
    hallId: 1,
    roomId: 'R003',
    applicationDate: DateTime.now().subtract(const Duration(days: 3)),
    status: 'Pending',
    studentName: 'Sohel Rana',
    roomNumber: '201',
    seatType: 'Single',
    seatNumber: 2,
    academicYear: '2024-25',
    semester: '3rd',
  ),
  SeatApplication(
    applicationId: 3,
    studentId: 'STU007',
    seatId: 3,
    hallId: 1,
    roomId: 'R005',
    applicationDate: DateTime.now().subtract(const Duration(days: 2)),
    status: 'Approved',
    studentName: 'Tanvir Ahmed',
    roomNumber: '301',
    seatType: 'Single',
    seatNumber: 1,
    academicYear: '2024-25',
    semester: '7th',
  ),
];

List<RoomAssignment> _mockAssignments() => [
  RoomAssignment(
    assignmentId: 1,
    studentId: 'STU003',
    hallId: 1,
    roomIdentity: '101/A',
    status: 'Active',
    assignmentDate: DateTime.now().subtract(const Duration(days: 30)),
    studentName: 'Mahfuz Alam',
    hallName: 'Zia Hall',
    faculty: 'ME',
    semester: 7,
    mobile: '01711-111111',
    bloodGroup: 'B+',
  ),
  RoomAssignment(
    assignmentId: 2,
    studentId: 'STU008',
    hallId: 1,
    roomIdentity: '101/A',
    status: 'Active',
    assignmentDate: DateTime.now().subtract(const Duration(days: 25)),
    studentName: 'Aminul Islam',
    hallName: 'Zia Hall',
    faculty: 'CSE',
    semester: 5,
    mobile: '01722-222222',
    bloodGroup: 'O+',
  ),
  RoomAssignment(
    assignmentId: 3,
    studentId: 'STU009',
    hallId: 1,
    roomIdentity: '102/A',
    status: 'Active',
    assignmentDate: DateTime.now().subtract(const Duration(days: 20)),
    studentName: 'Karim Hossain',
    hallName: 'Zia Hall',
    faculty: 'EEE',
    semester: 3,
    mobile: '01733-333333',
    bloodGroup: 'A+',
  ),
  RoomAssignment(
    assignmentId: 4,
    studentId: 'STU010',
    hallId: 1,
    roomIdentity: '201/B',
    status: 'Active',
    assignmentDate: DateTime.now().subtract(const Duration(days: 15)),
    studentName: 'Shahriar Kabir',
    hallName: 'Zia Hall',
    faculty: 'CE',
    semester: 7,
    mobile: '01744-444444',
    bloodGroup: 'AB+',
  ),
  RoomAssignment(
    assignmentId: 5,
    studentId: 'STU011',
    hallId: 1,
    roomIdentity: '202/B',
    status: 'Active',
    assignmentDate: DateTime.now().subtract(const Duration(days: 10)),
    studentName: 'Nur Mohammad',
    hallName: 'Zia Hall',
    faculty: 'WRE',
    semester: 5,
    mobile: '01755-555555',
    bloodGroup: 'O-',
  ),
];

List<RoomChangeRequest> _mockRoomChanges() => [
  RoomChangeRequest(
    requestId: 1,
    studentId: 'STU008',
    requestedRoomId: 'R003',
    requestedHallId: 1,
    status: 'Pending',
    requestDate: DateTime.now().subtract(const Duration(days: 1)),
    reason: 'Need quieter environment for studies',
    studentName: 'Aminul Islam',
    currentRoom: '101/A',
    requestedRoomNumber: '201',
  ),
  RoomChangeRequest(
    requestId: 2,
    studentId: 'STU009',
    requestedRoomId: 'R005',
    requestedHallId: 1,
    status: 'Pending',
    requestDate: DateTime.now().subtract(const Duration(hours: 6)),
    reason: 'Medical reasons - need ground floor room',
    studentName: 'Karim Hossain',
    currentRoom: '102/A',
    requestedRoomNumber: '301',
  ),
];

List<MaintenanceRequest> _mockMaintenance() => [
  MaintenanceRequest(
    requestId: 1,
    studentId: 'STU003',
    roomId: 'R001',
    hallId: 1,
    issue: 'Ceiling fan not working, needs repair or replacement',
    status: 'Pending',
    submittedOn: DateTime.now().subtract(const Duration(days: 2)),
    priority: 'High',
    studentName: 'Mahfuz Alam',
    roomNumber: '101',
  ),
  MaintenanceRequest(
    requestId: 2,
    studentId: 'STU009',
    roomId: 'R002',
    hallId: 1,
    issue: 'Bathroom tap is leaking continuously',
    status: 'InProgress',
    submittedOn: DateTime.now().subtract(const Duration(days: 3)),
    priority: 'Medium',
    studentName: 'Karim Hossain',
    roomNumber: '102',
    technicianNote: 'Plumber assigned, scheduled for tomorrow',
  ),
  MaintenanceRequest(
    requestId: 3,
    studentId: 'STU010',
    roomId: 'R003',
    hallId: 1,
    issue: 'Door lock is broken',
    status: 'Resolved',
    submittedOn: DateTime.now().subtract(const Duration(days: 7)),
    resolvedOn: DateTime.now().subtract(const Duration(days: 5)),
    priority: 'High',
    studentName: 'Shahriar Kabir',
    roomNumber: '201',
    technicianNote: 'Lock replaced with new digital lock',
  ),
  MaintenanceRequest(
    requestId: 4,
    studentId: 'STU011',
    roomId: 'R004',
    hallId: 1,
    issue: 'Window glass is cracked, needs urgent replacement',
    status: 'Pending',
    submittedOn: DateTime.now().subtract(const Duration(hours: 12)),
    priority: 'Medium',
    studentName: 'Nur Mohammad',
    roomNumber: '202',
  ),
];

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
      if (_isNetworkError(e)) {
        state = AsyncValue.data(_mockDashboardStats());
      } else {
        state = AsyncValue.error(e, st);
      }
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

class HallAdminRoomAppsNotifier
    extends StateNotifier<AsyncValue<List<RoomApplication>>> {
  final ApiService _api = ApiService();
  bool _mockMode = false;
  List<RoomApplication> _mockList = [];

  HallAdminRoomAppsNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getHallAdminRoomApplications();
      final list = (response.data as List)
          .map((e) => RoomApplication.fromJson(e))
          .where((a) => a.status == 'Pending')
          .toList();
      _mockMode = false;
      state = AsyncValue.data(list);
    } catch (e, st) {
      if (_isNetworkError(e)) {
        _mockMode = true;
        _mockList = _mockRoomApps()
            .where((a) => a.status == 'Pending')
            .toList();
        state = AsyncValue.data(List.from(_mockList));
      } else {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<bool> approve(int id, Map<String, dynamic> data) async {
    if (_mockMode) {
      _mockList = _mockList.where((a) => a.applicationId != id).toList();
      state = AsyncValue.data(List.from(_mockList));
      return true;
    }
    try {
      await _api.approveRoomApplication(id, data);
      await fetch();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> reject(int id, Map<String, dynamic> data) async {
    if (_mockMode) {
      _mockList = _mockList.where((a) => a.applicationId != id).toList();
      state = AsyncValue.data(List.from(_mockList));
      return true;
    }
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
    >((ref) => HallAdminRoomAppsNotifier());

class HallAdminSeatAppsNotifier
    extends StateNotifier<AsyncValue<List<SeatApplication>>> {
  final ApiService _api = ApiService();
  bool _mockMode = false;
  List<SeatApplication> _mockList = [];

  HallAdminSeatAppsNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getHallAdminSeatApplications();
      final list = (response.data as List)
          .map((e) => SeatApplication.fromJson(e))
          .where((a) => a.status == 'Pending')
          .toList();
      _mockMode = false;
      state = AsyncValue.data(list);
    } catch (e, st) {
      if (_isNetworkError(e)) {
        _mockMode = true;
        _mockList = _mockSeatApps()
            .where((a) => a.status == 'Pending')
            .toList();
        state = AsyncValue.data(List.from(_mockList));
      } else {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<bool> approve(int id, Map<String, dynamic> data) async {
    if (_mockMode) {
      _mockList = _mockList.where((a) => a.applicationId != id).toList();
      state = AsyncValue.data(List.from(_mockList));
      return true;
    }
    try {
      await _api.approveSeatApplication(id, data);
      await fetch();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> reject(int id, Map<String, dynamic> data) async {
    if (_mockMode) {
      _mockList = _mockList.where((a) => a.applicationId != id).toList();
      state = AsyncValue.data(List.from(_mockList));
      return true;
    }
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
    >((ref) => HallAdminSeatAppsNotifier());

class HallAdminRoomsNotifier extends StateNotifier<AsyncValue<List<Room>>> {
  final ApiService _api = ApiService();
  bool _mockMode = false;
  List<Room> _mockList = [];
  int _nextMockId = 7;

  HallAdminRoomsNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getHallAdminRooms();
      final list = (response.data as List)
          .map((e) => Room.fromJson(e))
          .toList();
      _mockMode = false;
      state = AsyncValue.data(list);
    } catch (e, st) {
      if (_isNetworkError(e)) {
        _mockMode = true;
        if (_mockList.isEmpty) _mockList = _mockRoomList();
        state = AsyncValue.data(List.from(_mockList));
      } else {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<bool> create(Map<String, dynamic> data) async {
    if (_mockMode) {
      final newId = _nextMockId++;
      final newRoom = Room(
        roomId: 'R${newId.toString().padLeft(3, "0")}',
        hallId: 1,
        roomCapacity: int.tryParse('${data['capacity'] ?? 4}') ?? 4,
        availableSlots: int.tryParse('${data['capacity'] ?? 4}') ?? 4,
        roomNumber: data['roomNumber'] as String? ?? 'New',
        roomName: data['roomName'] as String?,
        wing: data['wing'] as String?,
        block: data['block'] as String?,
        floor: int.tryParse('${data['floor'] ?? 1}'),
        status: 'Available',
      );
      _mockList = [..._mockList, newRoom];
      state = AsyncValue.data(List.from(_mockList));
      return true;
    }
    try {
      await _api.createRoom(data);
      await fetch();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> update(String id, Map<String, dynamic> data) async {
    if (_mockMode) {
      _mockList = _mockList.map((r) {
        if (r.roomId == id) {
          return Room(
            roomId: r.roomId,
            hallId: r.hallId,
            roomCapacity:
                int.tryParse('${data['capacity'] ?? r.roomCapacity}') ??
                r.roomCapacity,
            availableSlots: r.availableSlots,
            roomNumber: data['roomNumber'] as String? ?? r.roomNumber,
            roomName: data['roomName'] as String? ?? r.roomName,
            wing: data['wing'] as String? ?? r.wing,
            block: data['block'] as String? ?? r.block,
            floor: int.tryParse('${data['floor'] ?? r.floor}') ?? r.floor,
            status: data['status'] as String? ?? r.status,
          );
        }
        return r;
      }).toList();
      state = AsyncValue.data(List.from(_mockList));
      return true;
    }
    try {
      await _api.updateRoom(id, data);
      await fetch();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(String id) async {
    if (_mockMode) {
      _mockList = _mockList.where((r) => r.roomId != id).toList();
      state = AsyncValue.data(List.from(_mockList));
      return true;
    }
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
    StateNotifierProvider<HallAdminRoomsNotifier, AsyncValue<List<Room>>>(
      (ref) => HallAdminRoomsNotifier(),
    );

class HallAdminAssignmentsNotifier
    extends StateNotifier<AsyncValue<List<RoomAssignment>>> {
  final ApiService _api = ApiService();
  bool _mockMode = false;
  List<RoomAssignment> _mockList = [];

  HallAdminAssignmentsNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getHallAdminAssignments();
      final list = (response.data as List)
          .map((e) => RoomAssignment.fromJson(e))
          .toList();
      _mockMode = false;
      state = AsyncValue.data(list);
    } catch (e, st) {
      if (_isNetworkError(e)) {
        _mockMode = true;
        if (_mockList.isEmpty) _mockList = _mockAssignments();
        state = AsyncValue.data(List.from(_mockList));
      } else {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<bool> unassign(int id) async {
    if (_mockMode) {
      _mockList = _mockList.where((a) => a.assignmentId != id).toList();
      state = AsyncValue.data(List.from(_mockList));
      return true;
    }
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
    >((ref) => HallAdminAssignmentsNotifier());

class HallAdminRoomChangeNotifier
    extends StateNotifier<AsyncValue<List<RoomChangeRequest>>> {
  final ApiService _api = ApiService();
  bool _mockMode = false;
  List<RoomChangeRequest> _mockList = [];

  HallAdminRoomChangeNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getHallAdminRoomChangeRequests();
      final list = (response.data as List)
          .map((e) => RoomChangeRequest.fromJson(e))
          .toList();
      _mockMode = false;
      state = AsyncValue.data(list);
    } catch (e, st) {
      if (_isNetworkError(e)) {
        _mockMode = true;
        _mockList = _mockRoomChanges();
        state = AsyncValue.data(List.from(_mockList));
      } else {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<bool> process(int id, Map<String, dynamic> data) async {
    if (_mockMode) {
      final newStatus = data['status'] as String? ?? 'Approved';
      _mockList = _mockList
          .map(
            (r) => r.requestId == id
                ? RoomChangeRequest(
                    requestId: r.requestId,
                    studentId: r.studentId,
                    requestedRoomId: r.requestedRoomId,
                    requestedHallId: r.requestedHallId,
                    status: newStatus,
                    requestDate: r.requestDate,
                    processedDate: DateTime.now(),
                    reason: r.reason,
                    adminRemarks: data['remarks'] as String?,
                    studentName: r.studentName,
                    currentRoom: r.currentRoom,
                    requestedRoomNumber: r.requestedRoomNumber,
                  )
                : r,
          )
          .toList();
      state = AsyncValue.data(List.from(_mockList));
      return true;
    }
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
    >((ref) => HallAdminRoomChangeNotifier());

class HallAdminMaintenanceNotifier
    extends StateNotifier<AsyncValue<List<MaintenanceRequest>>> {
  final ApiService _api = ApiService();
  bool _mockMode = false;
  List<MaintenanceRequest> _mockList = [];

  HallAdminMaintenanceNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getHallAdminMaintenance();
      final list = (response.data as List)
          .map((e) => MaintenanceRequest.fromJson(e))
          .toList();
      _mockMode = false;
      state = AsyncValue.data(list);
    } catch (e, st) {
      if (_isNetworkError(e)) {
        _mockMode = true;
        if (_mockList.isEmpty) _mockList = _mockMaintenance();
        state = AsyncValue.data(List.from(_mockList));
      } else {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<bool> updateStatus(int id, Map<String, dynamic> data) async {
    if (_mockMode) {
      final newStatus = data['status'] as String? ?? 'InProgress';
      _mockList = _mockList
          .map(
            (r) => r.requestId == id
                ? MaintenanceRequest(
                    requestId: r.requestId,
                    studentId: r.studentId,
                    roomId: r.roomId,
                    hallId: r.hallId,
                    issue: r.issue,
                    status: newStatus,
                    submittedOn: r.submittedOn,
                    resolvedOn: newStatus == 'Resolved'
                        ? DateTime.now()
                        : r.resolvedOn,
                    technicianNote:
                        data['technicianNote'] as String? ?? r.technicianNote,
                    priority: r.priority,
                    studentName: r.studentName,
                    roomNumber: r.roomNumber,
                  )
                : r,
          )
          .toList();
      state = AsyncValue.data(List.from(_mockList));
      return true;
    }
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
    >((ref) => HallAdminMaintenanceNotifier());
