class SeatApplication {
  final int applicationId;
  final String studentId;
  final int seatId;
  final int hallId;
  final String roomId;
  final DateTime applicationDate;
  final String status;
  final String? studentRemarks;
  final String? adminRemarks;
  final DateTime? processedDate;
  final String? processedBy;
  final String? academicYear;
  final String? semester;
  final int? priorityScore;
  final String? studentName;
  final String? roomNumber;
  final String? seatType;
  final int? seatNumber;

  SeatApplication({
    required this.applicationId,
    required this.studentId,
    required this.seatId,
    required this.hallId,
    required this.roomId,
    required this.applicationDate,
    required this.status,
    this.studentRemarks,
    this.adminRemarks,
    this.processedDate,
    this.processedBy,
    this.academicYear,
    this.semester,
    this.priorityScore,
    this.studentName,
    this.roomNumber,
    this.seatType,
    this.seatNumber,
  });

  factory SeatApplication.fromJson(Map<String, dynamic> json) {
    return SeatApplication(
      applicationId: json['applicationId'] as int,
      studentId: json['studentId'] as String,
      seatId: json['seatId'] as int,
      hallId: json['hallId'] as int,
      roomId: json['roomId'] as String,
      applicationDate: DateTime.parse(json['applicationDate'] as String),
      status: json['status'] as String,
      studentRemarks: json['studentRemarks'] as String?,
      adminRemarks: json['adminRemarks'] as String?,
      processedDate: json['processedDate'] != null
          ? DateTime.parse(json['processedDate'] as String)
          : null,
      processedBy: json['processedBy'] as String?,
      academicYear: json['academicYear'] as String?,
      semester: json['semester'] as String?,
      priorityScore: json['priorityScore'] as int?,
      studentName: json['studentName'] as String?,
      roomNumber: json['roomNumber'] as String?,
      seatType: json['seatType'] as String?,
      seatNumber: json['seatNumber'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicationId': applicationId,
      'studentId': studentId,
      'seatId': seatId,
      'hallId': hallId,
      'roomId': roomId,
      'applicationDate': applicationDate.toIso8601String(),
      'status': status,
      'studentRemarks': studentRemarks,
      'adminRemarks': adminRemarks,
      'academicYear': academicYear,
      'semester': semester,
      'priorityScore': priorityScore,
    };
  }
}
