import Foundation
import HealthKit
import Combine

/// A simple manager that requests HealthKit authorization and fetches basic metrics: steps, heart rate (daily average), and sleep hours.
final class HealthDataManager: ObservableObject {
    private let healthStore = HKHealthStore()
    private var cancellables = Set<AnyCancellable>()

    @Published var steps: [HealthMetric] = []
    @Published var heartRates: [HealthMetric] = []
    @Published var sleepHours: [HealthMetric] = []

    init() {
        requestAuthorization()
    }

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available on this device.")
            return
        }

        let writeTypes: Set<HKSampleType> = []

        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]

        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
            if success {
                DispatchQueue.main.async {
                    self.fetchSteps()
                    self.fetchHeartRate()
                    self.fetchSleep()
                }
            } else if let err = error {
                print("HealthKit authorization error:\(err)")
            }
        }
    }

    // Fetch steps for the last 7 days (daily sums)
    func fetchSteps(days: Int = 7) {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }

        let (startDate, endDate) = Date.lastNDaysRange(n: days)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
        let anchorDate = Date.startOfDay()
        var interval = DateComponents()
        interval.day = 1

        let query = HKStatisticsCollectionQuery(quantityType: stepsType,
                                                quantitySamplePredicate: predicate,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)

        query.initialResultsHandler = { _, results, error in
            guard let stats = results else {
                print("No step stats: \(error?.localizedDescription ?? "unknown")")
                return
            }
            var daily: [HealthMetric] = []
            stats.enumerateStatistics(from: startDate, to: endDate) { stat, _ in
                let value = stat.sumQuantity()?.doubleValue(for: .count()) ?? 0
                daily.append(HealthMetric(date: stat.startDate, value: value))
            }
            DispatchQueue.main.async {
                self.steps = daily
            }
        }

        healthStore.execute(query)
    }

    // Fetch heart rate daily averages for the past N days
    func fetchHeartRate(days: Int = 7) {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }

        let (startDate, endDate) = Date.lastNDaysRange(n: days)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
        let anchorDate = Date.startOfDay()
        var interval = DateComponents()
        interval.day = 1

        // Use discreteAverage to get average heart rate per day
        let query = HKStatisticsCollectionQuery(quantityType: hrType,
                                                quantitySamplePredicate: predicate,
                                                options: .discreteAverage,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)

        query.initialResultsHandler = { _, results, error in
            guard let stats = results else {
                print("No heart rate stats: \(error?.localizedDescription ?? "unknown")")
                return
            }
            var daily: [HealthMetric] = []
            stats.enumerateStatistics(from: startDate, to: endDate) { stat, _ in
                let hrUnit = HKUnit(from: "count/min")
                let value = stat.averageQuantity()?.doubleValue(for: hrUnit) ?? 0
                daily.append(HealthMetric(date: stat.startDate, value: value))
            }
            DispatchQueue.main.async {
                self.heartRates = daily
            }
        }

        healthStore.execute(query)
    }

    // Fetch sleep hours per day for the past N days
    func fetchSleep(days: Int = 7) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }

        let (startDate, endDate) = Date.lastNDaysRange(n: days)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)

        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
            guard let samples = results as? [HKCategorySample] else {
                print("No sleep samples: \(error?.localizedDescription ?? "unknown")")
                return
            }

            // Aggregate total sleep hours by day
            var byDay: [Date: Double] = [:]
            for s in samples {
                let start = Calendar.current.startOfDay(for: s.startDate)
                let duration = s.endDate.timeIntervalSince(s.startDate)
                let hours = duration / 3600.0
                byDay[start, default: 0.0] += hours
            }

            var metrics: [HealthMetric] = []
            var current = startDate
            while current <= endDate {
                let dayStart = Calendar.current.startOfDay(for: current)
                let value = byDay[dayStart] ?? 0.0
                metrics.append(HealthMetric(date: dayStart, value: value))
                guard let next = Calendar.current.date(byAdding: .day, value: 1, to: current) else { break }
                current = next
            }

            DispatchQueue.main.async {
                self.sleepHours = metrics
            }
        }

        healthStore.execute(query)
    }
}
