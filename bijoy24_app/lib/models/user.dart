class AuthUser {
  final String userId;
  final String username;
  final String role;
  final String? studentId;
  final int? hallId;
  final String? name;
  final String token;

  AuthUser({
    required this.userId,
    required this.username,
    required this.role,
    this.studentId,
    this.hallId,
    this.name,
    required this.token,
  });

  bool get isStudent => role == 'Student';
  bool get isHallAdmin => role == 'HallAdmin';
  bool get isSystemAdmin => role == 'SystemAdmin';

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: json['userId'] as String,
      username: json['username'] as String,
      role: json['role'] as String,
      studentId: json['studentId'] as String?,
      hallId: json['hallId'] as int?,
      name: json['name'] as String?,
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'role': role,
      'studentId': studentId,
      'hallId': hallId,
      'name': name,
      'token': token,
    };
  }
}

class DashboardStats {
  final int totalHalls;
  final int totalRooms;
  final int totalStudents;
  final int totalAdmins;
  final int totalBoarderEntries;
  final int assignedRooms;
  final int pendingApplications;
  final int pendingMaintenance;

  DashboardStats({
    this.totalHalls = 0,
    this.totalRooms = 0,
    this.totalStudents = 0,
    this.totalAdmins = 0,
    this.totalBoarderEntries = 0,
    this.assignedRooms = 0,
    this.pendingApplications = 0,
    this.pendingMaintenance = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalHalls: json['totalHalls'] as int? ?? 0,
      totalRooms: json['totalRooms'] as int? ?? 0,
      totalStudents: json['totalStudents'] as int? ?? 0,
      totalAdmins: json['totalAdmins'] as int? ?? 0,
      totalBoarderEntries: json['totalBoarderEntries'] as int? ?? 0,
      assignedRooms: json['assignedRooms'] as int? ?? 0,
      pendingApplications: json['pendingApplications'] as int? ?? 0,
      pendingMaintenance: json['pendingMaintenance'] as int? ?? 0,
    );
  }
}
