class RoomApplication {
  final int applicationId;
  final String studentId;
  final int hallId;
  final String status;
  final DateTime applicationDate;
  final String? adminRemarks;
  final String? studentName;
  final String? hallName;
  final String? faculty;
  final int? semester;

  RoomApplication({
    required this.applicationId,
    required this.studentId,
    required this.hallId,
    required this.status,
    required this.applicationDate,
    this.adminRemarks,
    this.studentName,
    this.hallName,
    this.faculty,
    this.semester,
  });

  factory RoomApplication.fromJson(Map<String, dynamic> json) {
    return RoomApplication(
      applicationId: json['applicationId'] as int,
      studentId: json['studentId'] as String,
      hallId: json['hallId'] as int,
      status: json['status'] as String,
      applicationDate: DateTime.parse(json['applicationDate'] as String),
      adminRemarks: json['adminRemarks'] as String?,
      studentName: json['studentName'] as String?,
      hallName: json['hallName'] as String?,
      faculty: json['faculty'] as String?,
      semester: json['semester'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicationId': applicationId,
      'studentId': studentId,
      'hallId': hallId,
      'status': status,
      'applicationDate': applicationDate.toIso8601String(),
      'adminRemarks': adminRemarks,
    };
  }
}
