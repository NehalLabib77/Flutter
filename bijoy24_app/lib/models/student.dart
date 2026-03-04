class Student {
  final String studentId;
  final String studentName;
  final String gender;
  final String mobile;
  final String boarderNo;
  final String? bloodGroup;
  final String permanentAddress;
  final String? email;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String faculty;
  final int semester;
  final String status;
  final String? fatherName;
  final String? motherName;
  final String? religion;

  Student({
    required this.studentId,
    required this.studentName,
    required this.gender,
    required this.mobile,
    required this.boarderNo,
    this.bloodGroup,
    required this.permanentAddress,
    this.email,
    this.emergencyContactName,
    this.emergencyContactPhone,
    required this.faculty,
    required this.semester,
    required this.status,
    this.fatherName,
    this.motherName,
    this.religion,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      gender: json['gender'] as String,
      mobile: json['mobile'] as String,
      boarderNo: json['boarderNo'] as String,
      bloodGroup: json['bloodGroup'] as String?,
      permanentAddress: json['permanentAddress'] as String,
      email: json['email'] as String?,
      emergencyContactName: json['emergencyContactName'] as String?,
      emergencyContactPhone: json['emergencyContactPhone'] as String?,
      faculty: json['faculty'] as String,
      semester: json['semester'] as int,
      status: json['status'] as String,
      fatherName: json['fatherName'] as String?,
      motherName: json['motherName'] as String?,
      religion: json['religion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'gender': gender,
      'mobile': mobile,
      'boarderNo': boarderNo,
      'bloodGroup': bloodGroup,
      'permanentAddress': permanentAddress,
      'email': email,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'faculty': faculty,
      'semester': semester,
      'status': status,
      'fatherName': fatherName,
      'motherName': motherName,
      'religion': religion,
    };
  }

  Student copyWith({
    String? mobile,
    String? email,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? permanentAddress,
  }) {
    return Student(
      studentId: studentId,
      studentName: studentName,
      gender: gender,
      mobile: mobile ?? this.mobile,
      boarderNo: boarderNo,
      bloodGroup: bloodGroup,
      permanentAddress: permanentAddress ?? this.permanentAddress,
      email: email ?? this.email,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      faculty: faculty,
      semester: semester,
      status: status,
      fatherName: fatherName,
      motherName: motherName,
      religion: religion,
    );
  }
}
