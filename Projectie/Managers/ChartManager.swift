//
//  ChartManager.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 7/2/2025.
//

import Foundation
import SwiftData
import Combine

final class ChartManager: ObservableObject {
        
    static let shared = ChartManager()
    private var timeManager: TimeManager = TimeManager.shared
    private var financialEventManager: FinancialEventManager = FinancialEventManager.shared
    private var transactionManager = TransactionManager.shared
    private var balanceResetManager = BalanceResetManager.shared
    
    private init() { }
    
    
    @Published private(set) var chartDataPointsLine: [(date: Date, balance: Double)] = []
    
    @Published var isInteracting: Bool = false
    @Published var scrubHorozontalOffset: CGFloat = 0.0
    
    @Published var selectedDate: Date? = nil
    @Published var selectedBalance: Double? = nil
    
    @Published var goalsToDisplayOnChart: [Goal] = []
    
    
    
    var endOfRangeBalance: Double {
        guard let lastDataPoint = chartDataPointsLine.last else { return 0.0 }
        return lastDataPoint.balance
    }

    
    
    
    func recalculateChartDataPoints() {
        
        let calendar = Calendar.current
        
        let sortedTransactions = financialEventManager.allEvents.sorted { $0.date < $1.date }
        let sortedResets = balanceResetManager.resets.sorted { $0.date < $1.date }
        
        let latestResetBeforeStart = sortedResets.last(where: { $0.date <= timeManager.startDate })
        
        var runningBalance: Double
        var lastResetDate: Date
        
        if let reset = latestResetBeforeStart {
            runningBalance = reset.balanceAtReset
            lastResetDate = reset.date
        } else {
            runningBalance = 0
            lastResetDate = Date.distantPast
        }
        
        let transactionsBeforeStart = sortedTransactions.filter { $0.date > lastResetDate && $0.date < timeManager.startDate }
        for txn in transactionsBeforeStart {
            runningBalance += txn.transaction?.amount ?? 0
        }
        
        let resetsWithinTimeFrame = sortedResets.filter { $0.date >= timeManager.startDate && $0.date <= timeManager.endDate }
        let transactionsWithinTimeFrame = sortedTransactions.filter { $0.date >= timeManager.startDate && $0.date <= timeManager.endDate }
        
        let transactionsByDay = Dictionary(
            grouping: transactionsWithinTimeFrame
        ) { calendar.startOfDay(for: $0.date) }
        
        let resetsByDay = Dictionary(
            grouping: resetsWithinTimeFrame
        ) { calendar.startOfDay(for: $0.date) }
        
        var dataPoints: [(date: Date, balance: Double)] = []
        var currentDate = timeManager.startDate
        let endDate = timeManager.endDate
        
        while currentDate <= endDate {
            // Apply any resets on this day
            if let todaysResets = resetsByDay[currentDate] {
                for reset in todaysResets.sorted(by: { $0.date < $1.date }) {
                    runningBalance = reset.balanceAtReset
                }
            }
            
            if let todaysTransactions = transactionsByDay[currentDate] {
                for txn in todaysTransactions {
                    runningBalance += txn.transaction?.amount ?? 0
                }
            }
            
            dataPoints.append((date: currentDate, balance: runningBalance))
            
            // Move to the next day
            if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = nextDate
            } else {
                break
            }
        }
        
        chartDataPointsLine = dataPoints
    }
    
}
