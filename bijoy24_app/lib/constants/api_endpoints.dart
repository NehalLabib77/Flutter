class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - Change this to your actual backend URL
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // Auth
  static const String studentLogin = '/auth/student/login';
  static const String adminLogin = '/auth/admin/login';
  static const String studentRegister = '/auth/student/register';
  static const String hallAdminRegister = '/auth/halladmin/register';

  // Student
  static const String studentDashboard = '/student/dashboard';
  static const String studentProfile = '/student/profile';
  static const String studentRoomAssignment = '/student/room-assignment';
  static const String studentRoomApplication = '/student/room-application';
  static const String studentRoomApplicationStatus =
      '/student/room-application/status';
  static const String studentSeatApplication = '/student/seat-application';
  static const String studentSeatApplicationStatus =
      '/student/seat-application/status';
  static const String studentRoommates = '/student/roommates';
  static const String studentRoomChange = '/student/room-change';
  static const String studentRoomChangeHistory = '/student/room-change/history';
  static const String studentMaintenance = '/student/maintenance';

  // Halls & Rooms (shared)
  static const String halls = '/halls';
  static String hallRooms(int hallId) => '/halls/$hallId/rooms';
  static String roomSeats(String roomId, int hallId) =>
      '/rooms/$roomId/seats?hallId=$hallId';

  // Hall Admin
  static const String hallAdminDashboard = '/halladmin/dashboard';
  static const String hallAdminRoomApplications =
      '/halladmin/applications/rooms';
  static String hallAdminApproveRoomApp(int id) =>
      '/halladmin/applications/rooms/$id/approve';
  static String hallAdminRejectRoomApp(int id) =>
      '/halladmin/applications/rooms/$id/reject';
  static const String hallAdminSeatApplications =
      '/halladmin/applications/seats';
  static String hallAdminApproveSeatApp(int id) =>
      '/halladmin/applications/seats/$id/approve';
  static String hallAdminRejectSeatApp(int id) =>
      '/halladmin/applications/seats/$id/reject';
  static const String hallAdminRooms = '/halladmin/rooms';
  static String hallAdminRoom(String id) => '/halladmin/rooms/$id';
  static const String hallAdminAssignments = '/halladmin/assignments';
  static String hallAdminUnassign(int id) => '/halladmin/assignments/$id';
  static const String hallAdminMaintenance = '/halladmin/maintenance';
  static String hallAdminMaintenanceStatus(int id) =>
      '/halladmin/maintenance/$id/status';
  static const String hallAdminRoomChangeRequests =
      '/halladmin/room-change-requests';
  static String hallAdminRoomChangeRequest(int id) =>
      '/halladmin/room-change-requests/$id';

  // System Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminHalls = '/admin/halls';
  static String adminHall(int id) => '/admin/halls/$id';
  static const String adminHallAdmins = '/admin/halladmins';
  static String adminHallAdmin(int id) => '/admin/halladmins/$id';
  static const String adminBoarderRegistry = '/admin/boarder-registry';
  static String adminBoarderEntry(String boarderNo) =>
      '/admin/boarder-registry/$boarderNo';
  static const String adminStats = '/admin/stats';
}
