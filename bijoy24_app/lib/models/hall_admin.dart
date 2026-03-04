class HallAdmin {
  final int hallAdminId;
  final int hallId;
  final String? userId;
  final String adminName;
  final String? email;
  final String? phone;
  final String adminRole;
  final String status;
  final DateTime? startDate;
  final String? registrationToken;
  final bool isRegistered;
  final String? hallName;

  HallAdmin({
    required this.hallAdminId,
    required this.hallId,
    this.userId,
    required this.adminName,
    this.email,
    this.phone,
    this.adminRole = 'HallAdmin',
    required this.status,
    this.startDate,
    this.registrationToken,
    this.isRegistered = false,
    this.hallName,
  });

  factory HallAdmin.fromJson(Map<String, dynamic> json) {
    return HallAdmin(
      hallAdminId: json['hallAdminId'] as int,
      hallId: json['hallId'] as int,
      userId: json['userId'] as String?,
      adminName: json['adminName'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      adminRole: json['adminRole'] as String? ?? 'HallAdmin',
      status: json['status'] as String,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      registrationToken: json['registrationToken'] as String?,
      isRegistered: json['isRegistered'] as bool? ?? false,
      hallName: json['hallName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hallAdminId': hallAdminId,
      'hallId': hallId,
      'userId': userId,
      'adminName': adminName,
      'email': email,
      'phone': phone,
      'adminRole': adminRole,
      'status': status,
      'startDate': startDate?.toIso8601String(),
      'registrationToken': registrationToken,
      'isRegistered': isRegistered,
    };
  }
}
