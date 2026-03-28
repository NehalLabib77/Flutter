# BIJOY-24 হল ম্যানেজমেন্ট অ্যাপ্লিকেশন 📱

## প্রকল্পের সম্পূর্ণ গাইড (বাংলায়)

---

## 📋 বিষয়বস্তু
1. [প্রকল্প পরিচয়](#প্রকল্প-পরিচয়)
2. [প্রকল্পের কাঠামো](#প্রকল্পের-কাঠামো)
3. [প্রধান ফিচার](#প্রধান-ফিচার)
4. [ফোল্ডার বিস্তারিত ব্যাখ্যা](#ফোল্ডার-বিস্তারিত-ব্যাখ্যা)
5. [সাম্প্রতিক উন্নয়ন](#সাম্প্রতিক-উন্নয়ন)
6. [চালানোর নির্দেশ](#চালানোর-নির্দেশ)

---

## 🎯 প্রকল্প পরিচয়

**BIJOY-24** একটি **Flutter-ভিত্তিক মোবাইল অ্যাপ্লিকেশন** যা **হল/ডরমিটরি ম্যানেজমেন্ট** সিস্টেমের জন্য তৈরি।

### উদ্দেশ্য:
- 🏫 হলের ছাত্রদের রুম বুকিং এবং ম্যানেজমেন্ট
- 👨‍💼 হল প্রশাসকদের জন্য সহজ ম্যানেজমেন্ট পোর্টাল
- ⚙️ সিস্টেম অ্যাডমিনদের জন্য সম্পূর্ণ নিয়ন্ত্রণ ব্যবস্থা
- 🔧 রক্ষণাবেক্ষণ অনুরোধ এবং রুম পরিবর্তন সিস্টেম

### প্রযুক্তি স্ট্যাক:
- **ফ্রেমওয়ার্ক**: Flutter (Dart)
- **অবস্থা ব্যবস্থাপনা**: Riverpod
- **রাউটিং**: Go Router
- **সংরক্ষণ**: Flutter Secure Storage
- **API**: Dio (HTTP client)
- **ডাটাবেস**: ব্যাকএন্ডের সাথে REST API সংযোগ

---

## 📁 প্রকল্পের কাঠামো

```
bijoy24_app/
├── android/              → Android অ্যাপের জন্য নেটিভ কোড
├── ios/                  → iOS অ্যাপের জন্য নেটিভ কোড
├── lib/                  → মূল Dart কোড (এখানে সব কোড লিখা হয়)
├── web/                  → ওয়েব ভার্সনের জন্য HTML/CSS
├── test/                 → ইউনিট এবং উইজেট পরীক্ষা
├── pubspec.yaml          → প্রকল্পের কনফিগ এবং ডিপেন্ডেন্সি
└── .gitignore            → Git ইগনোর ফাইল
```

---

## 🚀 প্রধান ফিচার

### 👨‍🎓 **ছাত্রদের জন্য**
- ✅ অ্যাকাউন্ট নিবন্ধন এবং লগইন
- ✅ রুম বুকিং এবং আবেদন
- ✅ সিট নির্বাচন এবং বুকিং
- ✅ রুমমেটদের তথ্য দেখা
- ✅ রুম পরিবর্তনের অনুরোধ
- ✅ রক্ষণাবেক্ষণ সমস্যা রিপোর্ট করা

### 👨‍💼 **হল প্রশাসকদের জন্য**
- ✅ রুম তৈরি এবং সম্পাদনা
- ✅ ছাত্রদের আবেদন পর্যালোচনা এবং অনুমোদন
- ✅ রুম বরাদ্দ ব্যবস্থাপনা
- ✅ রুম পরিবর্তনের অনুরোধ হ্যান্ডেল করা
- ✅ রক্ষণাবেক্ষণ অনুরোধ পরিচালনা
- ✅ লজিন বাটন (সাম্প্রতিক সংযোজন)

### ⚙️ **সিস্টেম অ্যাডমিনদের জন্য**
- ✅ হল তৈরি এবং পরিচালনা
- ✅ হল প্রশাসক নিয়োগ
- ✅ বোর্ডার রেজিস্ট্রি পরিচালনা
- ✅ সিস্টেম-ব্যাপী রুম পর্যবেক্ষণ
- ✅ ডাটাবেস পরিসংখ্যান দেখা

---

## 📚 **LIB ফোল্ডারের বিস্তারিত কাঠামো**

### `lib/` - আপনার মূল কোড এখানে থাকে

```
lib/
├── main.dart                    ← অ্যাপের প্রবেশবিন্দু (সবচেয়ে গুরুত্বপূর্ণ)
├── constants/                   ← রঙ, থিম, টেক্সট সংরক্ষণ
├── models/                      ← ডেটা মডেল (ছাত্র, রুম, ইত্যাদি)
├── providers/                   ← অবস্থা ব্যবস্থাপনা (Riverpod)
├── routes/                      ← নেভিগেশন সেটআপ
├── screens/                     ← সব UI স্ক্রিন
├── services/                    ← API এবং স্টোরেজ লজিক
└── widgets/                     ← পুনরায় ব্যবহারযোগ্য UI উপাদান
```

---

## 🔍 প্রতিটি ফোল্ডারের বিস্তারিত ব্যাখ্যা

### 1️⃣ **main.dart** - অ্যাপের দিলের মতো ❤️

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: Bijoy24App()));
}
```

**কি কাজ করে:**
- অ্যাপ শুরু করে
- Riverpod প্রদানকারী সেটআপ করে
- বিশ্বব্যাপী স্থিতি ব্যবস্থাপনা সক্ষম করে

**কেন গুরুত্বপূর্ণ:**
- অ্যাপ রান করার জন্য এই ফাইলটি প্রয়োজন
- এটি সবকিছুর শুরু

---

### 2️⃣ **lib/constants/** - রঙ, থিম, ধ্রুবক

#### `app_colors.dart`
```dart
class AppColors {
  static const Color primary = Color(0xFF7C3AED);  // বেগুনী
  static const Color error = Color(0xFFEF4444);    // লাল
  // ... আরও রঙ
}
```

**উদ্দেশ্য:**
- একটি জায়গায় সব রঙ রাখা
- পুরো অ্যাপে ধারাবাহিকতা বজায় রাখা
- রঙ পরিবর্তন করা সহজ করা

#### `app_theme.dart`
```dart
static final lightTheme = ThemeData(
  primaryColor: AppColors.primary,
  // ... আরও থিম কনফিগ
);
```

**উদ্দেশ্য:**
- লাইট/ডার্ক থিম সেটআপ
- ফন্ট, বোতাম স্টাইল, আরও অনেক কিছু

---

### 3️⃣ **lib/models/** - ডেটা কাঠামো

```dart
// user.dart
class User {
  final String id;
  final String name;
  final String email;
  final String role; // 'Student', 'HallAdmin', 'SystemAdmin'
}

// room.dart
class Room {
  final String id;
  final String number;
  final int capacity;
  final int occupied;
  final List<String> occupantIds;
}
```

**কি জিনিস ডিফাইন করা আছে:**
- ব্যবহারকারী (ছাত্র, প্রশাসক)
- রুম এবং সিট
- আবেদন (রুম, সিট, পরিবর্তন)
- রক্ষণাবেক্ষণ অনুরোধ

**কেন দরকার:**
- ডেটা সংগঠিত রাখতে
- সার্ভার থেকে পাওয়া ডেটা স্থানীয়ভাবে ম্যাপ করতে

---

### 4️⃣ **lib/providers/** - অবস্থা ব্যবস্থাপনা (Riverpod)

```dart
// auth_provider.dart
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  Future<void> login(String email, String password) async {
    // API কল
    // ব্যবহারকারীর তথ্য সংরক্ষণ
    state = AuthState(status: AuthStatus.authenticated, user: user);
  }

  Future<void> logout() async {
    // সব ডেটা ক্লিয়ার করা
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
```

**Riverpod কি:**
- ব্যবহারকারীর তথ্য, রুম ডেটা ইত্যাদি সংরক্ষণ করে
- সব জায়গায় সহজে অ্যাক্সেস করা যায়

**অন্যান্য প্রোভাইডার:**
- `student_provider.dart` - ছাত্রের ড্যাশবোর্ড ডেটা
- `hall_admin_provider.dart` - হল প্রশাসকের ডেটা
- `system_admin_provider.dart` - সিস্টেম অ্যাডমিন ডেটা

---

### 5️⃣ **lib/services/** - API এবং স্টোরেজ

#### `api_service.dart`
```dart
class ApiService {
  // ইউজার অথেন্টিকেশনের জন্য API কল
  Future<LoginResponse> login(String email, String password) async {
    final response = await dio.post('/api/auth/login', data: {...});
    return LoginResponse.fromJson(response.data);
  }

  // রুম আবেদন জমা দেওয়ার জন্য
  Future<void> applyForRoom(String roomId) async {
    await dio.post('/api/rooms/apply', data: {'roomId': roomId});
  }
}
```

**কি কাজ করে:**
- সার্ভারের সাথে যোগাযোগ
- ডেটা পাঠানো এবং গ্রহণ করা

#### `storage_service.dart`
```dart
class StorageService {
  // টোকেন সংরক্ষণ করা (নিরাপদ)
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  // টোকেন পুনরুদ্ধার করা
  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // সব ডেটা মুছে ফেলা (লজিআউটের সময়)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
```

**দরকার কারণ:**
- লজইন টোকেন নিরাপদে রাখা
- ব্যবহারকারী অফলাইনে থাকলেও ডেটা রাখা

---

### 6️⃣ **lib/routes/** - নেভিগেশন

```dart
// app_router.dart
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      // লজইন করা হয়নি? লজইন পেজে পাঠাও
      if (!isAuth && !isLoginRoute) {
        return '/login';
      }
      // লজইন করা আছে এবং লজইন পেজে? ড্যাশবোর্ডে পাঠাও
      if (isAuth && isLoginRoute) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (ctx, state) => const LoginScreen()),
      GoRoute(path: '/student', builder: (ctx, state) => const StudentDashboard()),
      GoRoute(path: '/hall-admin', builder: (ctx, state) => const HallAdminDashboard()),
      // ... আরও রুট
    ],
  );
});
```

**কি করে:**
- পেজ থেকে পেজে নেভিগেশন
- লজইন করা ব্যবহারকারীদের ড্যাশবোর্ডে রিডিরেক্ট করা
- নিরাপত্তা নিশ্চিত করা

**রুট তালিকা:**
- `/login` - লজইন পেজ
- `/register/student` - ছাত্র নিবন্ধন
- `/student` - ছাত্রের ড্যাশবোর্ড
- `/hall-admin` - হল প্রশাসকের ড্যাশবোর্ড
- `/system-admin` - সিস্টেম অ্যাডমিনের ড্যাশবোর্ড

---

### 7️⃣ **lib/screens/** - সব UI স্ক্রিন

#### **auth/ - লজইন এবং নিবন্ধন**

```
lib/screens/auth/
├── login_screen.dart                    # লজইন ফর্ম
├── student_registration_screen.dart     # ছাত্র নিবন্ধন
└── hall_admin_registration_screen.dart  # হল অ্যাডমিন নিবন্ধন
```

**login_screen.dart এ কি আছে:**
```dart
class LoginScreen extends ConsumerWidget {
  // ইমেল এবং পাসওয়ার্ড ইনপুট ফিল্ড
  // লজইন বাটন
  // নিবন্ধন লিঙ্ক
}
```

**কি কাজ করে:**
- ব্যবহারকারীর ইমেল এবং পাসওয়ার্ড নেয়
- API এ পাঠায় যাচাইকরণের জন্য
- সফল হলে ড্যাশবোর্ডে নিয়ে যায়

---

#### **student/ - ছাত্রদের স্ক্রিন**

```
lib/screens/student/
├── student_dashboard.dart           # মূল ড্যাশবোর্ড
├── apply_room_screen.dart           # রুমের জন্য আবেদন করা
├── seat_booking_screen.dart         # সিট বেছে নেওয়া
├── roommates_screen.dart            # রুমমেটদের তথ্য
├── room_change_screen.dart          # রুম পরিবর্তনের অনুরোধ
├── submit_maintenance_screen.dart   # রক্ষণাবেক্ষণ সমস্যা রিপোর্ট
└── student_profile_screen.dart      # প্রোফাইল দেখা
```

**উদাহরণ - apply_room_screen.dart:**
```dart
class ApplyRoomScreen extends ConsumerWidget {
  // ছাত্র সব উপলব্ধ রুম দেখে
  // একটি রুম বেছে নেয় এবং আবেদন করে
  // বিজ্ঞপ্তি পায় যখন আবেদন অনুমোদিত হয়
}
```

---

#### **hall_admin/ - হল প্রশাসকের স্ক্রিন**

```
lib/screens/hall_admin/
├── hall_admin_dashboard.dart              # প্রশাসকের মূল ড্যাশবোর্ড
├── manage_rooms_screen.dart               # রুম যোগ/সম্পাদনা
├── create_room_screen.dart                # নতুন রুম তৈরি
├── room_applications_screen.dart          # আবেদন গুলি দেখা
├── room_assignments_screen.dart           # ছাত্রদের রুম বরাদ্দ করা
├── room_change_requests_screen.dart       # রুম পরিবর্তনের অনুরোধ
└── maintenance_requests_screen.dart       # রক্ষণাবেক্ষণ অনুরোধ
```

**হল_admin_dashboard.dart - বিস্তারিত:**

```dart
class HallAdminDashboardShell extends ConsumerWidget {
  // একটি সাধারণ শেল উইজেট যা অন্যদের ধারণ করে
}

class HallAdminHomeScreen extends ConsumerStatefulWidget {
  // প্রশাসকের মূল স্ক্রিন
  // শীর্ষে গ্র্যাডিয়েন্ট হেডার (নামসহ)
  
  Widget _buildHeader() {
    // নীল গ্র্যাডিয়েন্ট, নাম, লজিআউট বাটন প্রদর্শন
  }
}
```

**সাম্প্রতিক পরিবর্তন (যা আমি করেছি):**
- ✅ **লজিআউট বাটন যোগ করা**: ডান দিকে লজিআউট আইকন বাটন
- ✅ **ড্রয়ার সরানো**: আধুনিক কার্ড-ভিত্তিক নেভিগেশনে পরিবর্তন
- ✅ **গ্র্যাডিয়েন্ট হেডার উন্নত করা**: আরও পরিষ্কার এবং আধুনিক UI
- ✅ **দ্রুত অ্যাকশন গ্রিড**: সব ম্যানেজমেন্ট অপশন কার্ড হিসাবে

**লজিআউট কীভাবে কাজ করে:**
```dart
onPressed: () async {
  // প্রশাসকের ডেটা মুছে ফেলা
  await ref.read(authProvider.notifier).logout();
  
  // স্টোরেজ থেকে টোকেন মুছে ফেলা
  await StorageService.clearAll();
  
  // লজইন পেজে রিডিরেক্ট করা
  await Future.delayed(const Duration(milliseconds: 100));
  context.go('/login');
}
```

---

#### **system_admin/ - সিস্টেম অ্যাডমিনের স্ক্রিন**

```
lib/screens/system_admin/
├── system_admin_dashboard.dart      # সিস্টেম ড্যাশবোর্ড
├── manage_halls_screen.dart         # সব হল পরিচালনা
├── manage_hall_admins_screen.dart   # প্রশাসক নিয়োগ
├── boarder_registry_screen.dart     # সব ছাত্রের তালিকা
├── global_rooms_screen.dart         # সব হলের সব রুম
└── database_stats_screen.dart       # পরিসংখ্যান দেখা
```

---

### 8️⃣ **lib/widgets/** - পুনরায় ব্যবহারযোগ্য উপাদান

```dart
// stat_card.dart - পরিসংখ্যান প্রদর্শন কার্ড
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  
  // এটি ড্যাশবোর্ডে মোট রুম, মোট ছাত্র দেখায়
}

// error_retry_widget.dart - ত্রুটি পেজ
class ErrorRetryWidget extends StatelessWidget {
  // ত্রুটি বার্তা এবং পুনরায় চেষ্টা বাটন দেখায়
}

// loading_widget.dart - লোডিং স্পিনার
class LoadingWidget extends StatelessWidget {
  // ডেটা লোড হচ্ছে তখন দেখা যায়
}
```

**কেন আলাদা উপাদান থাকে:**
- একই কোড অনেক জায়গায় ব্যবহার হয়
- পরিবর্তন করা সহজ হয়
- পরিষ্কার এবং সংগঠিত থাকে

---

## 🔄 ডেটা প্রবাহ (সম্পূর্ণ উদাহরণ)

### উদাহরণ 1: ছাত্র রুমের জন্য আবেদন করা

```
1. ছাত্র আবেদন পেজ খোলে
   ↓
2. সব উপলব্ধ রুম লোড হয় (providers থেকে)
   ↓
3. ছাত্র একটি রুম বেছে নেয়
   ↓
4. "আবেদন করুন" বাটনে ক্লিক করে
   ↓
5. api_service.dart এ applyForRoom() কল হয়
   ↓
6. সার্ভারে API রিকোয়েস্ট পাঠানো হয়
   ↓
7. সার্ভার অনুমোদন করে এবং প্রতিক্রিয়া দেয়
   ↓
8. Provider স্থিতি আপডেট হয়
   ↓
9. UI রিফ্রেশ হয় এবং "আবেদন সফল" বার্তা প্রদর্শন হয়
```

### উদাহরণ 2: হল প্রশাসক রুম তৈরি করা

```
1. প্রশাসক "নতুন রুম" বাটনে ক্লিক করে
   ↓
2. create_room_screen খোলে
   ↓
3. প্রশাসক রুম নম্বর এবং ক্ষমতা প্রবেশ করে
   ↓
4. "তৈরি করুন" বাটনে ক্লিক
   ↓
5. api_service যাচাই করে এবং সার্ভারে পাঠায়
   ↓
6. সার্ভার রুম তৈরি করে এবং নিশ্চিত করে
   ↓
7. manage_rooms_screen এ নতুন রুম প্রদর্শিত হয়
   ↓
8. প্রশাসক সফলতার বার্তা পায়
```

### উদাহরণ 3: হল প্রশাসক লজিআউট করা (সাম্প্রতিক ফিচার)

```
1. প্রশাসক ড্যাশবোর্ডে থাকে
   ↓
2. উপরে ডানদিকে লজিআউট আইকন ক্লিক করে
   ↓
3. onPressed() ট্রিগার হয়:
   - storage_service.clearAll() - সব ডেটা মুছে দেয়
   - authProvider.logout() - স্টেট রিসেট করে
   ↓
4. Router লক্ষ্য করে যে অথ (authenticated = false)
   ↓
5. স্বয়ংক্রিয়ভাবে /login এ রিডিরেক্ট করে
   ↓
6. প্রশাসক লজইন পেজে ফিরে আসে
```

---

## 🛠️ সাম্প্রতিক উন্নয়ন

### করা পরিবর্তন:

#### 1. **হল প্রশাসকের জন্য লজিআউট ফিচার ✅**
- **ফাইল**: `lib/screens/hall_admin/hall_admin_dashboard.dart`
- **পরিবর্তন**: লজিআউট বাটন যোগ করা (ডান দিকে)
- **কোড**:
```dart
IconButton(
  onPressed: () async {
    await ref.read(authProvider.notifier).logout();
    await Future.delayed(const Duration(milliseconds: 100));
    if (context.mounted) {
      context.go('/login');
    }
  },
  icon: const Icon(Icons.logout_rounded, color: Colors.white),
  tooltip: 'লজিআউট',
),
```

#### 2. **হল প্রশাসক UI ডিজাইন আপগ্রেড ✅**
- **ফাইল**: `lib/screens/hall_admin/hall_admin_dashboard.dart`
- **পরিবর্তন**: 
  - ড্রয়ার সরানো (পুরানো)
  - আধুনিক কার্ড-ভিত্তিক নেভিগেশন যোগ করা
  - সিস্টেম অ্যাডমিনের মতো একই ডিজাইন
  - পরিষ্কার গ্র্যাডিয়েন্ট হেডার

#### 3. **রুম অ্যাপ্লিকেশন ত্রুটি সংশোধন ✅**
- **ফাইলগুলি**: 
  - `room_applications_screen.dart`
  - `seat_applications_screen.dart`
- **পরিবর্তন**: অপ্রয়োজনীয় null-aware অপারেটর সরানো
- **ফলাফল**: কম্পাইলেশন ত্রুটি সংশোধন

#### 4. **ছাত্র ড্যাশবোর্ড লজিআউট সংহত ✅**
- **ফাইল**: `lib/screens/student/student_dashboard.dart`
- **পরিবর্তন**: 
  - নেভিগেশন বার-এ লজিআউট অপশন যোগ করা (৪টি ট্যাব)
  - প্রোফাইল সরানো, লজিআউট যোগ করা
  - দ্রুত অ্যাক্সেস

---

## 🚀 চালানোর নির্দেশ

### ১. নতুন অ্যাপ তৈরি করা
```bash
flutter create my_app
cd my_app
flutter run
```

### ২. BIJOY-24 অ্যাপ চালানো
```bash
cd e:\Flutter\bijoy24_app
flutter run
```

### ৩. নির্দিষ্ট ডিভাইসে চালানো
```bash
# ডিভাইস তালিকা দেখুন
flutter devices

# নির্দিষ্ট ডিভাইসে চালান
flutter run -d <device_id>
```

### ৪. বিল্ড তৈরি করা (রিলিজ)
```bash
# Android APK তৈরি
flutter build apk --release

# iOS তৈরি (ম্যাক শুধুমাত্র)
flutter build ios --release
```

---

## 📝 কোড লেখার নিয়ম

### রুট তৈরি করা (নতুন পেজ যোগ করার সময়)
```dart
// app_router.dart এ যোগ করুন:
GoRoute(
  path: '/new-page',
  builder: (ctx, state) => const NewPageScreen(),
),
```

### নতুন প্রোভাইডার তৈরি করা
```dart
// lib/providers/new_provider.dart এ:
final newProvider = StateNotifierProvider<NewNotifier, NewState>((ref) {
  return NewNotifier();
});
```

### নতুন মডেল তৈরি করা
```dart
// lib/models/new_model.dart এ:
class NewModel {
  final String id;
  final String name;

  NewModel({required this.id, required this.name});

  factory NewModel.fromJson(Map<String, dynamic> json) {
    return NewModel(
      id: json['id'],
      name: json['name'],
    );
  }
}
```

---

## 🐛 সাধারণ সমস্যা এবং সমাধান

### সমস্যা 1: "Context is null" ত্রুটি
**কারণ**: Context পরিবর্তনের পরে ব্যবহার করা
**সমাধান**: `context.mounted` চেক করুন
```dart
if (context.mounted) {
  context.go('/login');
}
```

### সমস্যা 2: "null সেফটি" ত্রুটি
**কারণ**: null মান ব্যবহার করার চেষ্টা
**সমাধান**: null-coalescing operator ব্যবহার করুন
```dart
final name = user?.name ?? 'অজানা';
```

### সমস্যা 3: লজিআউট কাজ করছে না
**কারণ**: স্থিতি সঠিকভাবে আপডেট না হওয়া
**সমাধান**: `StorageService.clearAll()` এবং `logout()` উভয় করুন

---

## 📞 যোগাযোগ এবং সহায়তা

এই প্রকল্পের জন্য প্রশ্ন বা সমস্যার জন্য:
1. কোড মন্তব্য পড়ুন
2. Flutter ডকুমেন্টেশন চেক করুন
3. Riverpod গাইড পড়ুন

---

## 🎯 পরবর্তী শেখার পদক্ষেপ

1. **প্রতিটি স্ক্রিন পড়ুন এবং বুঝুন**
2. **API সার্ভিস কীভাবে কাজ করে তা শিখুন**
3. **নতুন ফিচার যোগ করার চেষ্টা করুন**
4. **ত্রুটি ঠিক করুন**

---

**তৈরি করা হয়েছে**: ২০২৬ সালে  
**সংস্করণ**: ১.০.০  
**স্থিতি**: সক্রিয় উন্নয়ন

---

**শুভকামনা! 🚀 সুখী কোডিং! 😊**
