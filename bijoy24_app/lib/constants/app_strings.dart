class AppStrings {
  AppStrings._();

  static const String appName = 'BIJOY-24';
  static const String appTitle = 'BIJOY-24 Hall Management';
  static const String appSubtitle = 'Residential Hall Management System';

  // Roles
  static const String roleStudent = 'Student';
  static const String roleHallAdmin = 'HallAdmin';
  static const String roleSystemAdmin = 'SystemAdmin';

  // Auth
  static const String login = 'Login';
  static const String register = 'Register';
  static const String studentLogin = 'Student Login';
  static const String adminLogin = 'Admin Login';
  static const String studentRegistration = 'Student Registration';
  static const String hallAdminRegistration = 'Hall Admin Registration';
  static const String username = 'Username';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String logout = 'Logout';

  // Student
  static const String studentId = 'Student ID';
  static const String boarderNo = 'Boarder Number';
  static const String fullName = 'Full Name';
  static const String mobile = 'Mobile';
  static const String gender = 'Gender';
  static const String bloodGroup = 'Blood Group';
  static const String faculty = 'Faculty';
  static const String semester = 'Semester';
  static const String permanentAddress = 'Permanent Address';
  static const String email = 'Email';
  static const String emergencyContactName = 'Emergency Contact Name';
  static const String emergencyContactPhone = 'Emergency Contact Phone';
  static const String fatherName = "Father's Name";
  static const String motherName = "Mother's Name";
  static const String religion = 'Religion';

  // Hall
  static const String hallName = 'Hall Name';
  static const String hallType = 'Hall Type';
  static const String hallCapacity = 'Hall Capacity';
  static const String location = 'Location';

  // Room
  static const String roomNumber = 'Room Number';
  static const String wing = 'Wing';
  static const String block = 'Block';
  static const String floor = 'Floor';
  static const String capacity = 'Capacity';
  static const String availableSlots = 'Available Slots';

  // Status
  static const String statusPending = 'Pending';
  static const String statusApproved = 'Approved';
  static const String statusRejected = 'Rejected';
  static const String statusActive = 'Active';
  static const String statusInactive = 'Inactive';
  static const String statusAvailable = 'Available';
  static const String statusOccupied = 'Occupied';
  static const String statusMaintenance = 'Maintenance';
  static const String statusInProgress = 'InProgress';
  static const String statusResolved = 'Resolved';
  static const String statusBooked = 'Booked';
  static const String statusReserved = 'Reserved';
  static const String statusCancelled = 'Cancelled';
  static const String statusExpired = 'Expired';

  // Seat Types
  static const String windowLeft = 'WINDOW_LEFT';
  static const String windowRight = 'WINDOW_RIGHT';
  static const String doorLeft = 'DOOR_LEFT';
  static const String doorRight = 'DOOR_RIGHT';

  // Priorities
  static const String priorityLow = 'Low';
  static const String priorityMedium = 'Medium';
  static const String priorityHigh = 'High';
  static const String priorityUrgent = 'Urgent';

  // Gender
  static const String male = 'MALE';
  static const String female = 'FEMALE';

  // Error Messages
  static const String errorRequired = 'This field is required';
  static const String errorInvalidEmail = 'Please enter a valid email';
  static const String errorPasswordMismatch = 'Passwords do not match';
  static const String errorPasswordTooShort =
      'Password must be at least 6 characters';
  static const String errorNetworkFailure = 'Network error. Please try again.';
  static const String errorUnauthorized =
      'Session expired. Please login again.';
  static const String errorServerError =
      'Server error. Please try again later.';

  // Success Messages
  static const String successRegistration =
      'Registration successful! Please login.';
  static const String successApplicationSubmitted =
      'Application submitted successfully.';
  static const String successMaintenanceSubmitted =
      'Maintenance request submitted.';
  static const String successRoomChangeSubmitted =
      'Room change request submitted.';
  static const String successProfileUpdated = 'Profile updated successfully.';

  // Faculties
  static const List<String> faculties = [
    'Engineering',
    'Science',
    'Arts',
    'Business Studies',
    'Law',
    'Medicine',
    'Social Science',
    'Agriculture',
  ];

  // Blood Groups
  static const List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
}
