class MaintenanceRequest {
  final int requestId;
  final String studentId;
  final String roomId;
  final int hallId;
  final String issue;
  final String status;
  final DateTime submittedOn;
  final DateTime? resolvedOn;
  final String? technicianNote;
  final String priority;
  final String? studentName;
  final String? roomNumber;

  MaintenanceRequest({
    required this.requestId,
    required this.studentId,
    required this.roomId,
    required this.hallId,
    required this.issue,
    required this.status,
    required this.submittedOn,
    this.resolvedOn,
    this.technicianNote,
    required this.priority,
    this.studentName,
    this.roomNumber,
  });

  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) {
    return MaintenanceRequest(
      requestId: json['requestId'] as int,
      studentId: json['studentId'] as String,
      roomId: json['roomId'] as String,
      hallId: json['hallId'] as int,
      issue: json['issue'] as String,
      status: json['status'] as String,
      submittedOn: DateTime.parse(json['submittedOn'] as String),
      resolvedOn: json['resolvedOn'] != null
          ? DateTime.parse(json['resolvedOn'] as String)
          : null,
      technicianNote: json['technicianNote'] as String?,
      priority: json['priority'] as String,
      studentName: json['studentName'] as String?,
      roomNumber: json['roomNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'studentId': studentId,
      'roomId': roomId,
      'hallId': hallId,
      'issue': issue,
      'status': status,
      'submittedOn': submittedOn.toIso8601String(),
      'resolvedOn': resolvedOn?.toIso8601String(),
      'technicianNote': technicianNote,
      'priority': priority,
    };
  }
}
