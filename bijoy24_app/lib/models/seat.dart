class Seat {
  final int seatId;
  final String roomId;
  final int hallId;
  final int seatNumber;
  final String seatType;
  final String status;
  final String? bookedByStudentId;
  final DateTime? bookingDate;
  final String? academicYear;

  Seat({
    required this.seatId,
    required this.roomId,
    required this.hallId,
    required this.seatNumber,
    required this.seatType,
    required this.status,
    this.bookedByStudentId,
    this.bookingDate,
    this.academicYear,
  });

  String get seatTypeDisplay {
    switch (seatType) {
      case 'WINDOW_LEFT':
        return 'Window Left';
      case 'WINDOW_RIGHT':
        return 'Window Right';
      case 'DOOR_LEFT':
        return 'Door Left';
      case 'DOOR_RIGHT':
        return 'Door Right';
      default:
        return seatType;
    }
  }

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      seatId: json['seatId'] as int,
      roomId: json['roomId'] as String,
      hallId: json['hallId'] as int,
      seatNumber: json['seatNumber'] as int,
      seatType: json['seatType'] as String,
      status: json['status'] as String,
      bookedByStudentId: json['bookedByStudentId'] as String?,
      bookingDate: json['bookingDate'] != null
          ? DateTime.parse(json['bookingDate'] as String)
          : null,
      academicYear: json['academicYear'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seatId': seatId,
      'roomId': roomId,
      'hallId': hallId,
      'seatNumber': seatNumber,
      'seatType': seatType,
      'status': status,
      'bookedByStudentId': bookedByStudentId,
      'bookingDate': bookingDate?.toIso8601String(),
      'academicYear': academicYear,
    };
  }
}
