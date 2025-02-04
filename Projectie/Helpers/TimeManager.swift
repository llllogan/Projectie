//
//  TimeManager.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 4/2/2025.
//

import Foundation
import Combine  // Only needed if you plan to use ObservableObject

enum TimePeriod {
    case week, fortnight, month, year, custom
}

class TimeManager: ObservableObject {  // Making it ObservableObject helps if you want UI updates.
    
    // MARK: - Singleton
    static let shared = TimeManager()
    private init() {
        calculateDates()
    }
    
    // MARK: - Properties
    @Published var timePeriod: TimePeriod = .week {
        didSet {
            if timePeriod != .custom {
                // Reset the offset when the type changes.
                periodOffset = 0
                calculateDates()
            }
        }
    }
    
    /// The starting date of the current period.
    @Published private(set) var startDate: Date = Date()
    /// The ending date of the current period.
    @Published private(set) var endDate: Date = Date()
    
    /// For non-custom periods, we keep track of an offset so that shifting the period updates the dates accordingly.
    private var periodOffset: Int = 0
    
    /// A Calendar configured to start weeks on Monday.
    private let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2  // Monday is represented by 2.
        return cal
    }()
    
    // MARK: - Helper Method for Date Calculation
    /// Returns a tuple containing the start and end dates for a given offset.
    /// - Parameter offset: For non-custom periods, the offset in units of the period. For example, for `.week` an offset of 1 means one week ahead.
    private func dates(for offset: Int) -> (start: Date, end: Date) {
        switch timePeriod {
        case .week:
            let now = Date()
            // Determine the current week interval (starting on Monday).
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else { return (Date(), Date()) }
            // The start of the period is the start of the week shifted by offset * 7 days.
            let start = calendar.date(byAdding: .day, value: offset * 7, to: weekInterval.start)!
            // The calendar’s week interval ends on the following Monday, so subtract one day to get Sunday.
            let end = calendar.date(byAdding: .day, value: offset * 7 - 1, to: weekInterval.end)!
            return (start, end)
            
        case .fortnight:
            let now = Date()
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else { return (Date(), Date()) }
            // Each offset unit here represents 14 days.
            let start = calendar.date(byAdding: .day, value: offset * 14, to: weekInterval.start)!
            // A fortnight spans 14 days (start on Monday, end on the Sunday of the next week).
            let end = calendar.date(byAdding: .day, value: 13, to: start)!
            return (start, end)
            
        case .month:
            let now = Date()
            // Get the first day of the current month.
            var components = calendar.dateComponents([.year, .month], from: now)
            components.day = 1
            let currentMonthStart = calendar.date(from: components)!
            // Shift the month by the given offset.
            let start = calendar.date(byAdding: .month, value: offset, to: currentMonthStart)!
            // Determine the last day of this month.
            let nextMonth = calendar.date(byAdding: .month, value: 1, to: start)!
            let end = calendar.date(byAdding: .day, value: -1, to: nextMonth)!
            return (start, end)
            
        case .year:
            let now = Date()
            // Get the first day of the current year.
            var components = calendar.dateComponents([.year], from: now)
            components.month = 1
            components.day = 1
            let currentYearStart = calendar.date(from: components)!
            // Shift the year by the offset.
            let start = calendar.date(byAdding: .year, value: offset, to: currentYearStart)!
            // Determine December 31 by getting the day before the next year's start.
            let nextYear = calendar.date(byAdding: .year, value: 1, to: start)!
            let end = calendar.date(byAdding: .day, value: -1, to: nextYear)!
            return (start, end)
            
        case .custom:
            // For custom periods, use the interval between start and end.
            let interval = endDate.timeIntervalSince(startDate)
            let newStart = startDate.addingTimeInterval(Double(offset) * interval)
            let newEnd = endDate.addingTimeInterval(Double(offset) * interval)
            return (newStart, newEnd)
        }
    }
    
    // MARK: - Current Period Calculation
    /// Recalculate the start and end dates for the current period (using periodOffset).
    func calculateDates() {
        let currentDates = dates(for: periodOffset)
        startDate = currentDates.start
        endDate = currentDates.end
    }
    
    // MARK: - Computed Properties for Adjacent Periods
    /// The previous period (one period behind the current).
    var previousPeriod1: (start: Date, end: Date) {
        return dates(for: periodOffset - 1)
    }
    
    /// The period before the previous one (two periods behind the current).
    var previousPeriod2: (start: Date, end: Date) {
        return dates(for: periodOffset - 2)
    }
    
    /// The next period (one period ahead of the current).
    var nextPeriod1: (start: Date, end: Date) {
        return dates(for: periodOffset + 1)
    }
    
    /// The period after the next (two periods ahead of the current).
    var nextPeriod2: (start: Date, end: Date) {
        return dates(for: periodOffset + 2)
    }
    
    // MARK: - Shifting the Period
    /// Shifts the current period by a given value.
    /// - Parameter value: A positive value moves the period forward, a negative value moves it backward.
    func shiftPeriod(by value: Int) {
        if timePeriod == .custom {
            let interval = endDate.timeIntervalSince(startDate)
            startDate = startDate.addingTimeInterval(Double(value) * interval)
            endDate = endDate.addingTimeInterval(Double(value) * interval)
        } else {
            periodOffset += value
            calculateDates()
        }
    }
    
    /// Optionally, reset the period offset back to 0 (i.e. the "current" period).
    func resetToCurrentPeriod() {
        periodOffset = 0
        calculateDates()
    }
}
