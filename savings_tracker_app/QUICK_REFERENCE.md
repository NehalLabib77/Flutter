# Savings Tracker App - Quick Reference

## 🎯 Core Features

### Dashboard

- Real-time savings balance
- Current target progress
- Color-coded status (Green/Orange/Red)
- Quick action buttons

### Add Savings

- Amount input
- Optional notes
- Date selection
- Real-time balance update

### Target Setup

- Set target amount & deadline
- Automatic daily savings calculation
- Rollover logic for missed targets
- Unmet amount tracking

### History
- Daily savings log
- Target history
- Status tracking
- Delete functionality

---

## 🔧 Developer Quick Start

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Build release APK
flutter build apk --release
```

---

## 📊 Key Classes

### SavingsProvider (State Management)
```dart
// Create/Update targets
provider.setTarget(amount, date)
provider.updateTargetWithRollover(amount, date)

// Add savings
provider.addSavings(amount, note, date)

// Get data
provider.totalBalance        // Total saved
provider.currentTarget       // Active target
provider.remainingAmount     // To reach goal
provider.progressPercentage  // 0.0-1.0
provider.requiredDailySavings
```

### Models
- **SavingsEntry**: Single transaction
- **SavingsTarget**: Savings goal

---

## 🎨 UI Components

| Screen | Purpose |
|--------|---------|
| HomeScreen | Dashboard & overview |
| AddSavingsScreen | Record new savings |
| TargetSetupScreen | Set/update goals |
| HistoryScreen | View logs |

---

## 💾 Data Storage

**Hive Database**
- Box 'savings': All transactions
- Box 'targets': All goals
- Local only, no cloud

---

## 🔄 Rollover Logic

When target deadline is missed:

```text
Previous Target: $100
Saved: $50
Unmet: $50

New Target Entered: $150
Actual New Target: $150 + $50 = $200
```

---

## 📱 Color Coding

| Status | Color |
| --- | --- |
| On Track | 🟢 Green |
| Behind | 🟠 Orange |
| Missed | 🔴 Red |

---

## 🧪 Quick Test

1. **Set Target**: $100, 30 days
2. **Add Savings**: $25 (25% progress)
3. **Expected**: Green, "On Track"
4. **Add Savings**: $75 (100% progress)
5. **Expected**: Green, "Completed"

---

## 📝 File Locations

```
lib/
├── main.dart                 ← Entry point
├── providers/savings_provider.dart    ← Logic
├── models/{entry,target}.dart         ← Data classes
└── screens/                           ← UI
```

---

## 🛠️ Common Tasks

### Add New Field to Savings Entry
1. Update `savings_entry.dart` model
2. Update adapter in `.g.dart` file
3. Adjust storage logic in provider
4. Update UI screens using field

### Add New Screen
1. Create file in `lib/screens/`
2. Use `Consumer<SavingsProvider>` for state
3. Navigate with `Navigator.push()`
4. Link from existing screens

### Change Colors
Update in individual screens or create `lib/theme/colors.dart`

---

## 📚 Dependencies

- **provider**: State management
- **hive**: Local database
- **intl**: Date formatting
- **flutter_spinkit**: Loading animations

---

## ⚠️ Troubleshooting

| Issue | Solution |
|-------|----------|
| App won't start | `flutter clean` then `flutter pub get` |
| Data not saving | Check Hive initialization |
| Build errors | Run `flutter pub get` again |

---

## 🚀 Deployment

```bash
# Android APK
flutter build apk --release

# Find APK at:
# build/app/outputs/flutter-apk/app-release.apk
```

---

**Version**: 1.0.0 | **Status**: Production Ready
