# BIJOY-24

A hall management app built with Flutter for university residential halls. The idea was to replace the usual paper-based process — room applications, maintenance reports, seat assignments — with something students and admins can just use from their phones.

There are three types of users in the system: students, hall admins, and a system admin. Each one sees a completely different part of the app.

---

## What each role can do

**Students** can register and log in, then apply for a room or book a specific seat. If they want to shift to a different room later, they can put in a room change request. There's also a section to report maintenance problems (broken fans, plumbing issues, etc.) and track whether anything has been done about it. A roommates tab shows who else is in the same room, and there's a profile page to manage their own info.

**Hall admins** manage everything inside their assigned hall. They can add or edit rooms, go through incoming room and seat applications, approve or reject them, and keep track of who's assigned where. When a student requests a room change, it shows up in the admin panel too. Maintenance requests from students land here as well, so the admin can update their status as things get fixed.

**The system admin** has a bird's-eye view of the whole system — all halls, all rooms, all admins. They can create new halls, assign hall admins to them, manage the boarder registry, and check database stats. Basically anything that affects the system as a whole goes through here.

---

## Built with

- Flutter
- Riverpod for state management
- GoRouter for navigation
- Dio for API calls
- Flutter Secure Storage for keeping auth tokens safe
- JSON Annotation for model serialization

---

## Folder structure
lib/
├── main.dart
├── constants/
├── models/
├── providers/
├── routes/
├── screens/
│   ├── auth/
│   ├── student/
│   ├── hall_admin/
│   └── system_admin/
├── services/
└── widgets/
