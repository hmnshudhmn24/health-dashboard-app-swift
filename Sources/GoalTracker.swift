import Foundation
import Combine

final class GoalTracker: ObservableObject {
    @Published var dailyStepGoal: Int = 10000
    @Published var achieved: Bool = false

    func checkGoal(steps: Double) {
        achieved = steps >= Double(dailyStepGoal)
    }

    func updateGoal(to newGoal: Int) {
        dailyStepGoal = newGoal
    }
}
