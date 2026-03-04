import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            StorageService.clearAll();
          }
          handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  // ===== AUTH =====
  Future<Response> studentLogin(String username, String password) {
    return _dio.post(
      ApiEndpoints.studentLogin,
      data: {'username': username, 'password': password},
    );
  }

  Future<Response> adminLogin(String username, String password, String role) {
    return _dio.post(
      ApiEndpoints.adminLogin,
      data: {'username': username, 'password': password, 'role': role},
    );
  }

  Future<Response> registerStudent(Map<String, dynamic> data) {
    return _dio.post(ApiEndpoints.studentRegister, data: data);
  }

  Future<Response> registerHallAdmin(Map<String, dynamic> data) {
    return _dio.post(ApiEndpoints.hallAdminRegister, data: data);
  }

  // ===== STUDENT =====
  Future<Response> getStudentDashboard() {
    return _dio.get(ApiEndpoints.studentDashboard);
  }

  Future<Response> getStudentProfile() {
    return _dio.get(ApiEndpoints.studentProfile);
  }

  Future<Response> updateStudentProfile(Map<String, dynamic> data) {
    return _dio.put(ApiEndpoints.studentProfile, data: data);
  }

  Future<Response> getRoomAssignment() {
    return _dio.get(ApiEndpoints.studentRoomAssignment);
  }

  Future<Response> submitRoomApplication(Map<String, dynamic> data) {
    return _dio.post(ApiEndpoints.studentRoomApplication, data: data);
  }

  Future<Response> getRoomApplicationStatus() {
    return _dio.get(ApiEndpoints.studentRoomApplicationStatus);
  }

  Future<Response> submitSeatApplication(Map<String, dynamic> data) {
    return _dio.post(ApiEndpoints.studentSeatApplication, data: data);
  }

  Future<Response> getSeatApplicationStatus() {
    return _dio.get(ApiEndpoints.studentSeatApplicationStatus);
  }

  Future<Response> getRoommates() {
    return _dio.get(ApiEndpoints.studentRoommates);
  }

  Future<Response> submitRoomChangeRequest(Map<String, dynamic> data) {
    return _dio.post(ApiEndpoints.studentRoomChange, data: data);
  }

  Future<Response> getRoomChangeHistory() {
    return _dio.get(ApiEndpoints.studentRoomChangeHistory);
  }

  Future<Response> getStudentMaintenance() {
    return _dio.get(ApiEndpoints.studentMaintenance);
  }

  Future<Response> submitMaintenanceRequest(Map<String, dynamic> data) {
    return _dio.post(ApiEndpoints.studentMaintenance, data: data);
  }

  // ===== HALLS & ROOMS (shared) =====
  Future<Response> getHalls() {
    return _dio.get(ApiEndpoints.halls);
  }

  Future<Response> getHallRooms(int hallId) {
    return _dio.get(ApiEndpoints.hallRooms(hallId));
  }

  Future<Response> getRoomSeats(String roomId, int hallId) {
    return _dio.get(ApiEndpoints.roomSeats(roomId, hallId));
  }

  // ===== HALL ADMIN =====
  Future<Response> getHallAdminDashboard() {
    return _dio.get(ApiEndpoints.hallAdminDashboard);
  }

  Future<Response> getHallAdminRoomApplications() {
    return _dio.get(ApiEndpoints.hallAdminRoomApplications);
  }

  Future<Response> approveRoomApplication(int id, Map<String, dynamic> data) {
    return _dio.put(ApiEndpoints.hallAdminApproveRoomApp(id), data: data);
  }

  Future<Response> rejectRoomApplication(int id, Map<String, dynamic> data) {
    return _dio.put(ApiEndpoints.hallAdminRejectRoomApp(id), data: data);
  }

  Future<Response> getHallAdminSeatApplications() {
    return _dio.get(ApiEndpoints.hallAdminSeatApplications);
  }

  Future<Response> approveSeatApplication(int id, Map<String, dynamic> data) {
    return _dio.put(ApiEndpoints.hallAdminApproveSeatApp(id), data: data);
  }

  Future<Response> rejectSeatApplication(int id, Map<String, dynamic> data) {
    return _dio.put(ApiEndpoints.hallAdminRejectSeatApp(id), data: data);
  }

  Future<Response> getHallAdminRooms() {
    return _dio.get(ApiEndpoints.hallAdminRooms);
  }

  Future<Response> createRoom(Map<String, dynamic> data) {
    return _dio.post(ApiEndpoints.hallAdminRooms, data: data);
  }

  Future<Response> updateRoom(String id, Map<String, dynamic> data) {
    return _dio.put(ApiEndpoints.hallAdminRoom(id), data: data);
  }

  Future<Response> deleteRoom(String id) {
    return _dio.delete(ApiEndpoints.hallAdminRoom(id));
  }

  Future<Response> getHallAdminAssignments() {
    return _dio.get(ApiEndpoints.hallAdminAssignments);
  }

  Future<Response> unassignStudent(int id) {
    return _dio.delete(ApiEndpoints.hallAdminUnassign(id));
  }

  Future<Response> getHallAdminMaintenance() {
    return _dio.get(ApiEndpoints.hallAdminMaintenance);
  }

  Future<Response> updateMaintenanceStatus(int id, Map<String, dynamic> data) {
    return _dio.put(ApiEndpoints.hallAdminMaintenanceStatus(id), data: data);
  }

  Future<Response> getHallAdminRoomChangeRequests() {
    return _dio.get(ApiEndpoints.hallAdminRoomChangeRequests);
  }

  Future<Response> processRoomChangeRequest(int id, Map<String, dynamic> data) {
    return _dio.put(ApiEndpoints.hallAdminRoomChangeRequest(id), data: data);
  }

  // ===== SYSTEM ADMIN =====
  Future<Response> getAdminDashboard() {
    return _dio.get(ApiEndpoints.adminDashboard);
  }

  Future<Response> getAdminHalls() {
    return _dio.get(ApiEndpoints.adminHalls);
  }

  Future<Response> createHall(Map<String, dynamic> data) {
    return _dio.post(ApiEndpoints.adminHalls, data: data);
  }

  Future<Response> updateHall(int id, Map<String, dynamic> data) {
    return _dio.put(ApiEndpoints.adminHall(id), data: data);
  }

  Future<Response> deleteHall(int id) {
    return _dio.delete(ApiEndpoints.adminHall(id));
  }

  Future<Response> getAdminHallAdmins() {
    return _dio.get(ApiEndpoints.adminHallAdmins);
  }

  Future<Response> createHallAdmin(Map<String, dynamic> data) {
    return _dio.post(ApiEndpoints.adminHallAdmins, data: data);
  }

  Future<Response> updateHallAdmin(int id, Map<String, dynamic> data) {
    return _dio.put(ApiEndpoints.adminHallAdmin(id), data: data);
  }

  Future<Response> deleteHallAdmin(int id) {
    return _dio.delete(ApiEndpoints.adminHallAdmin(id));
  }

  Future<Response> getBoarderRegistry() {
    return _dio.get(ApiEndpoints.adminBoarderRegistry);
  }

  Future<Response> createBoarderEntry(Map<String, dynamic> data) {
    return _dio.post(ApiEndpoints.adminBoarderRegistry, data: data);
  }

  Future<Response> updateBoarderEntry(
    String boarderNo,
    Map<String, dynamic> data,
  ) {
    return _dio.put(ApiEndpoints.adminBoarderEntry(boarderNo), data: data);
  }

  Future<Response> deleteBoarderEntry(String boarderNo) {
    return _dio.delete(ApiEndpoints.adminBoarderEntry(boarderNo));
  }

  Future<Response> getAdminStats() {
    return _dio.get(ApiEndpoints.adminStats);
  }
}
