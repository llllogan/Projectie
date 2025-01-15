//
//  ComputeRecurrence.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 15/1/2025.
//

import Foundation

func computeRecurrenceDates(
    startDate: Date,
    frequency: RecurrenceFrequency,
    interval: Int,
    maxOccurrences: Int? = nil,    // optional limit by count
    endDate: Date? = nil           // optional limit by date
) -> [Date] {
    var results: [Date] = []
    let calendar = Calendar.current
    
    var mxOc: Int? = nil
    var edDt: Date? = nil
    
    if (maxOccurrences == nil && endDate == nil) {
        mxOc = 10000
        edDt = Date.distantFuture
    } else {
        mxOc = maxOccurrences
        edDt = endDate
    }
    
    // Always include the startDate as the first occurrence
    results.append(startDate)
    
    // We'll keep adding occurrences until we hit an end date or max occurrence count
    while true {
        // If we have maxOccurrences, check if we reached that
        if let max = mxOc, results.count >= max {
            break
        }
        
        // Get the last date we added
        guard let current = results.last else { break }
        
        // Add the next date based on frequency + interval
        var nextDate: Date?
        
        switch frequency {
        case .daily:
            nextDate = calendar.date(byAdding: .day, value: interval, to: current)
        case .weekly:
            nextDate = calendar.date(byAdding: .weekOfYear, value: interval, to: current)
        case .monthly:
            nextDate = calendar.date(byAdding: .month, value: interval, to: current)
        case .yearly:
            nextDate = calendar.date(byAdding: .year, value: interval, to: current)
        }
        
        guard let next = nextDate else { break }
        
        // Check if next date is beyond our endDate (if any)
        if let limit = edDt, next > limit {
            break
        }
        
        results.append(next)
    }
    
    return results
}
