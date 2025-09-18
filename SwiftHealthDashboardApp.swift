import SwiftUI

@main
struct SwiftHealthDashboardApp: App {
    @StateObject private var healthManager = HealthDataManager()
    @StateObject private var goalTracker = GoalTracker()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthManager)
                .environmentObject(goalTracker)
        }
    }
}
