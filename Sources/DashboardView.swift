import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var healthManager: HealthDataManager
    @EnvironmentObject var goalTracker: GoalTracker

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                header

                if !healthManager.steps.isEmpty {
                    stepsCard
                } else {
                    placeholderCard(title: "Steps", subtitle: "No data yet — grant HealthKit permission and open Health app data.")
                }

                if !healthManager.heartRates.isEmpty {
                    heartRateCard
                }

                if !healthManager.sleepHours.isEmpty {
                    sleepCard
                }

                Spacer()
            }
            .padding(.vertical)
        }
        .onAppear {
            healthManager.fetchSteps()
            healthManager.fetchHeartRate()
            healthManager.fetchSleep()
            // update goal status (simple example)
            if let todaySteps = healthManager.steps.last?.value {
                goalTracker.checkGoal(steps: todaySteps)
            }
        }
    }

    var header: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Your Health").font(.largeTitle).bold()
                Text("Weekly overview").font(.subheadline).foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(goalTracker.achieved ? "🎉 Goal reached" : "Keep going").font(.headline)
                Text("Daily step goal: \(goalTracker.dailyStepGoal)").font(.caption)
            }
        }
        .padding(.horizontal)
    }

    func placeholderCard(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            Text(subtitle).font(.caption).foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    var stepsCard: some View {
        VStack(alignment: .leading) {
            Text("Steps — Last 7 days").font(.headline).padding(.horizontal)
            Chart(healthManager.steps) { item in
                BarMark(x: .value("Day", item.date, unit: .day),
                        y: .value("Steps", item.value))
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 220)
            .padding()
        }
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    var heartRateCard: some View {
        VStack(alignment: .leading) {
            Text("Avg Heart Rate — Last 7 days").font(.headline).padding(.horizontal)
            Chart(healthManager.heartRates) { item in
                LineMark(x: .value("Day", item.date, unit: .day),
                         y: .value("BPM", item.value))
                PointMark(x: .value("Day", item.date, unit: .day),
                          y: .value("BPM", item.value))
            }
            .frame(height: 200)
            .padding()
        }
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    var sleepCard: some View {
        VStack(alignment: .leading) {
            Text("Sleep Hours — Last 7 days").font(.headline).padding(.horizontal)
            Chart(healthManager.sleepHours) { item in
                BarMark(x: .value("Day", item.date, unit: .day),
                        y: .value("Hours", item.value))
            }
            .frame(height: 200)
            .padding()
        }
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(HealthDataManager())
            .environmentObject(GoalTracker())
    }
}
