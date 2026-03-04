class Hall {
  final int hallId;
  final String hallName;
  final String hallType;
  final int hallCapacity;
  final String? location;

  Hall({
    required this.hallId,
    required this.hallName,
    required this.hallType,
    required this.hallCapacity,
    this.location,
  });

  factory Hall.fromJson(Map<String, dynamic> json) {
    return Hall(
      hallId: json['hallId'] as int,
      hallName: json['hallName'] as String,
      hallType: json['hallType'] as String,
      hallCapacity: json['hallCapacity'] as int,
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hallId': hallId,
      'hallName': hallName,
      'hallType': hallType,
      'hallCapacity': hallCapacity,
      'location': location,
    };
  }

  Hall copyWith({
    int? hallId,
    String? hallName,
    String? hallType,
    int? hallCapacity,
    String? location,
  }) {
    return Hall(
      hallId: hallId ?? this.hallId,
      hallName: hallName ?? this.hallName,
      hallType: hallType ?? this.hallType,
      hallCapacity: hallCapacity ?? this.hallCapacity,
      location: location ?? this.location,
    );
  }
}
