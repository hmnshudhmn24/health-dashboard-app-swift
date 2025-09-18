import Foundation

extension Date {
    static func startOfDay(_ date: Date = Date()) -> Date {
        return Calendar.current.startOfDay(for: date)
    }

    static func daysAgo(_ days: Int, from date: Date = Date()) -> Date {
        return Calendar.current.date(byAdding: .day, value: -days, to: date) ?? date
    }

    static func lastNDaysRange(n: Int) -> (start: Date, end: Date) {
        let end = Date()
        let start = Calendar.current.date(byAdding: .day, value: -n+1, to: Date.startOfDay(end)) ?? Date.startOfDay(end)
        return (start, end)
    }
}

extension Double {
    /// Return rounded to integer (useful for steps)
    var roundedInt: Int { Int(self.rounded()) }
}
