class Room {
  final String roomId;
  final int hallId;
  final int roomCapacity;
  final int availableSlots;
  final String? roomName;
  final String? wing;
  final String? block;
  final int? floor;
  final String? roomNumber;
  final String status;

  Room({
    required this.roomId,
    required this.hallId,
    required this.roomCapacity,
    required this.availableSlots,
    this.roomName,
    this.wing,
    this.block,
    this.floor,
    this.roomNumber,
    required this.status,
  });

  String get roomIdentity => '${roomNumber ?? roomId}/${wing ?? ''}';

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomId: json['roomId'] as String,
      hallId: json['hallId'] as int,
      roomCapacity: json['roomCapacity'] as int,
      availableSlots: json['availableSlots'] as int,
      roomName: json['roomName'] as String?,
      wing: json['wing'] as String?,
      block: json['block'] as String?,
      floor: json['floor'] as int?,
      roomNumber: json['roomNumber'] as String?,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'hallId': hallId,
      'roomCapacity': roomCapacity,
      'availableSlots': availableSlots,
      'roomName': roomName,
      'wing': wing,
      'block': block,
      'floor': floor,
      'roomNumber': roomNumber,
      'status': status,
    };
  }

  Room copyWith({
    String? roomId,
    int? hallId,
    int? roomCapacity,
    int? availableSlots,
    String? roomName,
    String? wing,
    String? block,
    int? floor,
    String? roomNumber,
    String? status,
  }) {
    return Room(
      roomId: roomId ?? this.roomId,
      hallId: hallId ?? this.hallId,
      roomCapacity: roomCapacity ?? this.roomCapacity,
      availableSlots: availableSlots ?? this.availableSlots,
      roomName: roomName ?? this.roomName,
      wing: wing ?? this.wing,
      block: block ?? this.block,
      floor: floor ?? this.floor,
      roomNumber: roomNumber ?? this.roomNumber,
      status: status ?? this.status,
    );
  }
}
