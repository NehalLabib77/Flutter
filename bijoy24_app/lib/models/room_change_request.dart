class RoomChangeRequest {
  final int requestId;
  final String studentId;
  final String requestedRoomId;
  final int requestedHallId;
  final String status;
  final DateTime requestDate;
  final DateTime? processedDate;
  final String? reason;
  final String? adminRemarks;
  final String? studentName;
  final String? currentRoom;
  final String? requestedRoomNumber;

  RoomChangeRequest({
    required this.requestId,
    required this.studentId,
    required this.requestedRoomId,
    required this.requestedHallId,
    required this.status,
    required this.requestDate,
    this.processedDate,
    this.reason,
    this.adminRemarks,
    this.studentName,
    this.currentRoom,
    this.requestedRoomNumber,
  });

  factory RoomChangeRequest.fromJson(Map<String, dynamic> json) {
    return RoomChangeRequest(
      requestId: json['requestId'] as int,
      studentId: json['studentId'] as String,
      requestedRoomId: json['requestedRoomId'] as String,
      requestedHallId: json['requestedHallId'] as int,
      status: json['status'] as String,
      requestDate: DateTime.parse(json['requestDate'] as String),
      processedDate: json['processedDate'] != null
          ? DateTime.parse(json['processedDate'] as String)
          : null,
      reason: json['reason'] as String?,
      adminRemarks: json['adminRemarks'] as String?,
      studentName: json['studentName'] as String?,
      currentRoom: json['currentRoom'] as String?,
      requestedRoomNumber: json['requestedRoomNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'studentId': studentId,
      'requestedRoomId': requestedRoomId,
      'requestedHallId': requestedHallId,
      'status': status,
      'requestDate': requestDate.toIso8601String(),
      'reason': reason,
      'adminRemarks': adminRemarks,
    };
  }
}
