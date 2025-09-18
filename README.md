# 🩺 Swift Health Dashboard — gen-ai

Visualize your Apple Health data with a clean SwiftUI dashboard. This starter app reads steps, heart rate averages, and sleep hours using **HealthKit** and presents beautiful charts using Apple's **Charts** framework.

## Features

- 📊 Steps, heart rate, and sleep visualizations (last 7 days)
- 🎯 Daily step goal tracking
- 🔔 Reminder scheduling via local notifications
- ⚙️ Modular SwiftUI + HealthKit architecture

## Requirements

- Xcode 14+ (Xcode 15 recommended)
- iOS 16+ device (HealthKit and Charts require a real device)
- Health data in the Health app (or simulated via Health app export/import)

## Quickstart

1. Clone the repo and open in Xcode:
```bash
git clone https://github.com/yourusername/Swift-Health-Dashboard.git
open Swift-Health-Dashboard/SwiftHealthDashboard.xcodeproj
```

2. In the project settings -> Signing & Capabilities add **HealthKit** capability.
3. Add `NSHealthShareUsageDescription` and `NSHealthUpdateUsageDescription` to your Info.plist (already included in the sample Info.plist).
4. Run on a real device (HealthKit isn't available on the Simulator). Grant Health permissions when prompted.
5. Optionally schedule reminders:
```swift
RemindersManager.shared.scheduleHourlyReminder()
```

## Architecture notes

- `HealthDataManager` handles HealthKit authorization and queries.
- `DashboardView` renders charts for each metric and a header with the daily goal status.
- `GoalTracker` keeps a simple daily step goal and can be integrated with HealthKit write APIs if desired.
- `RemindersManager` wraps local notification scheduling.

## Extending the project

- Add more metrics (calories, active energy, workouts).
- Persist user preferences and goals to iCloud or CoreData.
- Use on-device ML to detect patterns over longer time ranges.
- Add Insights cards with suggested actions based on trends.

## Privacy & Security

- This app reads HealthKit data — make sure to disclose to users how data is used and never transmit sensitive data without explicit consent.
- Be mindful of HealthKit privacy rules and App Store requirements if you publish the app.

## License

MIT © 2025
