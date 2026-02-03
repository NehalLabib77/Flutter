# Savings Tracker App - Setup & Development Guide

## Project Overview

The **Savings Tracker App** is a feature-rich Android application built with Flutter that helps users achieve their financial goals through intelligent savings tracking and management.

## Quick Start

### Prerequisites

- Flutter SDK (3.10.7 or higher)
- Dart SDK (3.10.7 or higher)
- Android SDK 21 or higher
- Android Studio or VS Code with Flutter extension

### Setup Steps

1. **Navigate to project directory**:

   ```bash
   cd e:\Flutter\savings_tracker_app
   ```

2. **Install dependencies**:

   ```bash
   flutter pub get
   ```

3. **Get available devices**:

   ```bash
   flutter devices
   ```

4. **Run the app**:

   ```bash
   flutter run
   ```

## Architecture Overview

### State Management (Provider Pattern)

The app uses the Provider package for state management, centralizing all business logic in `SavingsProvider`:

```dart
// Access provider in widgets
Consumer<SavingsProvider>(
  builder: (context, provider, _) {
    // provider.totalBalance
    // provider.currentTarget
    // provider.addSavings()
  }
)
```

### Data Persistence (Hive)

All data is stored locally using Hive - a fast, lightweight NoSQL database:

- **Box 'savings'**: Stores individual savings entries
- **Box 'targets'**: Stores all savings targets
- **Box 'settings'**: Stores app settings

### Models

**SavingsEntry** - Represents a single savings transaction
- `date`: DateTime of the transaction
- `amount`: Amount saved
- `note`: Optional transaction note

**SavingsTarget** - Represents a savings goal
- `targetAmount`: Goal amount
- `targetDate`: Deadline
- `createdDate`: When target was created
- `isCompleted`: Completion status
- `isMissed`: Whether deadline was missed

## Core Features

### 1. Dashboard (HomeScreen)

**Location**: `lib/screens/home_screen.dart`

#### Features

- Total balance display with gradient card
- Current target with progress metrics
- Progress bar with color coding
- Quick action buttons
- Floating action button for adding savings

#### State Management

- Watches `provider.totalBalance`
- Watches `provider.currentTarget`
- Watches `provider.progressPercentage`

### 2. Add Savings (AddSavingsScreen)

**Location**: `lib/screens/add_savings_screen.dart`

#### Add Savings Features

- Amount input validation
- Date picker (can track past savings)
- Optional note field
- Form validation before saving

#### Methods Used

- `provider.addSavings(amount, note, date)`

### 3. Target Setup (TargetSetupScreen)

**Location**: `lib/screens/target_setup_screen.dart`

#### Target Setup Features

- Target amount input
- Date picker with validation
- Rollover logic explanation
- Unmet amount automatic calculation

#### Methods Used

- `provider.setTarget(amount, date)` - New target
- `provider.updateTargetWithRollover(amount, date)` - With rollover

### 4. History (HistoryScreen)

**Location**: `lib/screens/history_screen.dart`

Two tabs:1. **Daily Savings**
   - Grouped by date
   - Shows daily totals
   - Delete functionality

2. **Targets**
   - All past and current targets
   - Status indicators
   - Days remaining calculation

## Business Logic

### Progress Calculation

```dart
// Color-coded based on pace
double progress = currentSavings / targetAmount;

if (progress >= 1) {
  color = GREEN;  // Completed
} else if (progress >= expectedProgress) {
  color = GREEN;  // On track
} else if (progress >= expectedProgress * 0.75) {
  color = ORANGE;  // Behind
} else {
  color = RED;  // Significantly behind
}
```

### Rollover Logic

When target deadline is missed:

```text
unmetAmount = targetAmount - totalSaved
newTarget = userEnteredAmount + unmetAmount
// All previous savings remain in balance
// New target created with combined amount
```

### Required Daily Savings

```dart
remainingAmount = targetAmount - currentSavings
daysRemaining = targetDate - today
requiredDaily = remainingAmount / daysRemaining
```

## File Structure

```
lib/
├── main.dart
│   └── App initialization with Provider setup
│
├── providers/
│   └── savings_provider.dart
│       ├── SavingsProvider class
│       ├── Data loading/persistence
│       ├── Business logic methods
│       └── State notifications
│
├── models/
│   ├── savings_entry.dart
│   │   ├── SavingsEntry class (Hive model)
│   │   └── savings_entry.g.dart (generated adapter)
│   │
│   └── savings_target.dart
│       ├── SavingsTarget class (Hive model)
│       └── savings_target.g.dart (generated adapter)
│
└── screens/
    ├── home_screen.dart
    │   └── Main dashboard UI
    │
    ├── add_savings_screen.dart
    │   └── Form to add new savings
    │
    ├── target_setup_screen.dart
    │   └── Form to set/update targets
    │
    └── history_screen.dart
        ├── Daily savings tab
        └── Targets history tab
```

## Key Methods in SavingsProvider

### Initialization

```dart
Future<void> initialize()
// Initializes Hive boxes and loads data
// Must be called before using provider
```

### Data Management

```dart
Future<void> addSavings(double amount, {String? note, DateTime? date})
// Add new savings entry

Future<void> setTarget(double targetAmount, DateTime targetDate)
// Create new target

Future<void> updateTargetWithRollover(double newTargetAmount, DateTime newTargetDate)
// Update target with rollover logic
```

### Getters (for UI)

```dart
double get totalBalance              // Total accumulated savings
SavingsTarget? get currentTarget     // Active target
List<SavingsEntry> get savingsHistory
List<SavingsTarget> get targetHistory
double get remainingAmount           // To reach target
double get progressPercentage        // 0.0 to 1.0
Color get progressColor              // Based on pace
int get remainingDays
double get requiredDailySavings
```

## UI Components

### Color Scheme

- **Primary**: Blue (#2196F3)
- **Success**: Green (#4CAF50)
- **Warning**: Orange (#FF9800)
- **Danger**: Red (#F44336)
- **Backgrounds**: White, Gray[50]

### Card Components

All screens use elevated cards with rounded corners for consistency.

### Progress Indicators

- Linear progress bar with color coding
- Percentage display
- Remaining/saved amounts

## Testing Scenarios

### Test 1: Basic Savings

1. Open app
2. Tap "Set Target"
3. Enter amount: 100, Date: 30 days from now
4. Tap "Add Savings" button
5. Enter amount: 25, Date: today
6. Verify progress shows 25%

### Test 2: Target Completion

1. Set target: 100
2. Add savings: 100
3. Should show "Completed" with green checkmark
4. Allow setting new target

### Test 3: Missed Target Rollover

1. Set target: 100, Date: yesterday
2. Add savings: 50
3. Update target: 150, Date: 30 days from now
4. New required should be: 200 (150 + 50 unmet)

### Test 4: Delete Entry

1. Add multiple savings on same day
2. Go to History tab
3. Tap entry delete button
4. Verify balance updates

## Dependencies

| Package | Version | Purpose |
| --- | --- | --- |
| hive | ^2.2.3 | Database |
| hive_flutter | ^1.1.0 | Hive Flutter support |
| provider | ^6.0.0 | State management |
| intl | ^0.19.0 | Date formatting |
| flutter_spinkit | ^5.2.0 | Loading spinners (optional) |

## Building & Deployment

### Build APK (Debug)

```bash
flutter build apk --debug
```

### Build APK (Release)

```bash
flutter build apk --release
```

### Install on Device

```bash
flutter install
```

## Troubleshooting

### App won't start

```bash
flutter clean
flutter pub get
flutter run
```

### Hive database errors
- Clear app data from device settings
- Delete `build/` folder
- Rebuild app

### Import errors in generated files
- Run build_runner if needed:
  ```bash
  flutter pub run build_runner build
  ```

## Future Enhancement Ideas

1. **Notifications**
   - Daily reminder at specific time
   - Deadline approaching alert
   - Target completed celebration

2. **Analytics**
   - Savings trends chart
   - Monthly comparison
   - Average daily savings

3. **Customization**
   - Dark mode
   - Theme colors
   - Currency selection

4. **Advanced Features**
   - Multiple concurrent targets
   - Savings categories
   - Recurring automatic savings
   - Goal templates

5. **Data Management**
   - Export to CSV
   - Cloud backup (optional)
   - Import previous data

## Code Quality

- **Pattern**: MVC with Provider
- **State Management**: ChangeNotifier
- **Data Validation**: Input checking in forms
- **Error Handling**: Try-catch in async operations
- **Comments**: Well-documented complex logic

## Performance Considerations

- Hive is faster than SQLite for simple operations
- Provider rebuilds only affected widgets
- Lists are sorted once on load
- No unnecessary rebuilds with Consumer pattern

---

**Last Updated**: February 2026
**Version**: 1.0.0
**Status**: Production Ready
