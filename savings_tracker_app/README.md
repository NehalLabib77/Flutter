# Savings Tracker App

A modern Flutter mobile application that helps users set financial goals and track daily savings with automatic rollover logic for missed targets.

## Features

### 🏠 Dashboard

- **Total Savings Balance**: Real-time display of all accumulated savings
- **Current Target Overview**: View target amount, deadline, and progress
- **Progress Indicator**: Visual progress bar with color coding
- **Quick Stats**: Remaining amount, days left, and required daily savings

### 💰 Add Savings

- Input daily savings amounts
- Optional notes for transactions
- Date selection (track past or current day savings)
- Real-time balance updates

### 🎯 Target Management

- Set new savings goals with target amounts and deadlines
- Automatic calculation of required daily savings
- Rollover logic for missed targets (unmet amount rolls over)
- Track target completion and missed deadlines

### 📊 History

- **Daily Savings Log**: View all transactions grouped by date
- **Target History**: Complete record of past and current targets
- **Status Tracking**: See which targets were completed, missed, or are active
- Delete individual savings entries

## Technical Stack

- **Framework**: Flutter (Android)
- **State Management**: Provider
- **Local Database**: Hive
- **Date Formatting**: intl

## Project Structure

```text
lib/
├── main.dart                 # App entry point
├── providers/
│   └── savings_provider.dart # State management logic
├── models/
│   ├── savings_entry.dart    # Savings transaction model
│   └── savings_target.dart   # Target goal model
└── screens/
    ├── home_screen.dart          # Dashboard
    ├── add_savings_screen.dart    # Add transaction
    ├── target_setup_screen.dart   # Target management
    └── history_screen.dart        # History and logs
```

## Installation & Setup

1. Install dependencies:

   ```bash
   flutter pub get
   ```

2. Run the app:

   ```bash
   flutter run
   ```

## Key Features Implemented

✅ **Dashboard** with total savings, current target, progress indicator
✅ **Add Savings** with amount, note, and date selection
✅ **Target Setup** with automatic daily savings calculation
✅ **Missed Target Rollover** - unmet amounts automatically roll over
✅ **History Tracking** - daily savings log and target history
✅ **Local Storage** - Hive database for persistent data
✅ **Color-Coded Progress** - Green (on track), Orange (behind), Red (missed)
✅ **Real-time Updates** - Provider state management
✅ **Offline-First** - Works completely without internet

## Usage Guide

**Setting a Savings Goal:**

1. Tap "Set Target" and enter amount
2. Select target deadline
3. App calculates required daily savings

**Tracking Daily Savings:**

1. Tap floating "Add Savings" button
2. Enter amount and optional note
3. Select date (defaults to today)

**Handling Missed Targets:**

- When deadline passes without reaching goal, app marks as "Missed"
- Unmet amount automatically adds to new target
- All previous savings remain in balance

**Viewing History:**

- Daily Savings Tab: Transactions grouped by date
- Targets Tab: All past and current targets with status
