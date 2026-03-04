class BoarderRegistry {
  final int registryId;
  final String boarderNo;
  final String? studentName;
  final String? studentId;
  final String status;
  final int? hallId;
  final String? hallName;
  final String? roomNumber;
  final String? department;
  final String? session;

  BoarderRegistry({
    required this.registryId,
    required this.boarderNo,
    this.studentName,
    this.studentId,
    required this.status,
    this.hallId,
    this.hallName,
    this.roomNumber,
    this.department,
    this.session,
  });

  factory BoarderRegistry.fromJson(Map<String, dynamic> json) {
    return BoarderRegistry(
      registryId: json['registryId'] as int? ?? 0,
      boarderNo: json['boarderNo'] as String,
      studentName: json['studentName'] as String?,
      studentId: json['studentId'] as String?,
      status: json['status'] as String,
      hallId: json['hallId'] as int?,
      hallName: json['hallName'] as String?,
      roomNumber: json['roomNumber'] as String?,
      department: json['department'] as String?,
      session: json['session'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'registryId': registryId,
      'boarderNo': boarderNo,
      'studentName': studentName,
      'studentId': studentId,
      'status': status,
      'hallId': hallId,
      'hallName': hallName,
      'roomNumber': roomNumber,
      'department': department,
      'session': session,
    };
  }
}
