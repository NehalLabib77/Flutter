class RoomAssignment {
  final int assignmentId;
  final String studentId;
  final int hallId;
  final String roomIdentity;
  final String status;
  final DateTime assignmentDate;
  final String? studentName;
  final String? hallName;
  final String? faculty;
  final int? semester;
  final String? mobile;
  final String? bloodGroup;

  RoomAssignment({
    required this.assignmentId,
    required this.studentId,
    required this.hallId,
    required this.roomIdentity,
    required this.status,
    required this.assignmentDate,
    this.studentName,
    this.hallName,
    this.faculty,
    this.semester,
    this.mobile,
    this.bloodGroup,
  });

  factory RoomAssignment.fromJson(Map<String, dynamic> json) {
    return RoomAssignment(
      assignmentId: json['assignmentId'] as int,
      studentId: json['studentId'] as String,
      hallId: json['hallId'] as int,
      roomIdentity: json['roomIdentity'] as String,
      status: json['status'] as String,
      assignmentDate: DateTime.parse(json['assignmentDate'] as String),
      studentName: json['studentName'] as String?,
      hallName: json['hallName'] as String?,
      faculty: json['faculty'] as String?,
      semester: json['semester'] as int?,
      mobile: json['mobile'] as String?,
      bloodGroup: json['bloodGroup'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignmentId': assignmentId,
      'studentId': studentId,
      'hallId': hallId,
      'roomIdentity': roomIdentity,
      'status': status,
      'assignmentDate': assignmentDate.toIso8601String(),
    };
  }
}
