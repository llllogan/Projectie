//
//  FinancialEventManager.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 6/2/2025.
//

import Foundation
import SwiftData
import Combine
import SwiftUI

final class FinancialEventManager: ObservableObject {
 
    static let shared = FinancialEventManager()
    private var timeManager: TimeManager = TimeManager.shared
    private var balanceResetManager: BalanceResetManager = BalanceResetManager.shared
    
    private init() { }
    
    @Published private(set) var eventLintMinus2: [(key: Date, value: [FinancialEventOccurence])]?
    @Published private(set) var eventListMinus1: [(key: Date, value: [FinancialEventOccurence])]?
    @Published private(set) var eventList: [(key: Date, value: [FinancialEventOccurence])]?
    @Published private(set) var eventListPlus1: [(key: Date, value: [FinancialEventOccurence])]?
    @Published private(set) var eventListPlus2: [(key: Date, value: [FinancialEventOccurence])]?
    
    @Published private(set) var allEvents: [FinancialEventOccurence] = []
    
    
    var visibleEventOccurences: [FinancialEventOccurence] {
        allEvents.filter {
            $0.date >= timeManager.startDate && $0.date <= timeManager.endDate
        }
    }
    
    
    // TODO: Could be improved to a published variable and only updated when there is a change
    var currentBalance: Double {
        guard let reset = balanceResetManager.resets.last else {
            return sumOfAllTransactionsUpTo(Date())
        }
        
        let baseline = reset.balanceAtReset
        let resetDate = reset.date
        
        let sumAfterReset = allEvents
            .filter { $0.date > resetDate && $0.date <= Date() }
            .reduce(0) { $0 + ($1.transaction?.amount ?? 0) }
        
        return baseline + sumAfterReset
    }
    
    
    func doUpdates() {
        updateAllEvents()
        updateEventLists()
    }
    
    
    private func updateEventLists() {
        
        eventLintMinus2 = compileGroupedEventList(from: timeManager.previousPeriod2.start, to: timeManager.previousPeriod2.end)
        eventListMinus1 = compileGroupedEventList(from: timeManager.previousPeriod1.start, to: timeManager.previousPeriod1.end)
        eventList = compileGroupedEventList(from: timeManager.startDate, to: timeManager.endDate)
        eventListPlus1 = compileGroupedEventList(from: timeManager.nextPeriod1.start, to: timeManager.nextPeriod1.end)
        eventListPlus2 = compileGroupedEventList(from: timeManager.nextPeriod2.start, to: timeManager.nextPeriod2.end)
        
    }

    
    private func updateAllEvents() {
        
        let transactionOccurrences = TransactionManager.shared.transactions.flatMap { txn in
            if txn.isRecurring {
                return txn.recurrenceDates.compactMap { date in
                    FinancialEventOccurence(type: .transaction(txn), recurringTransactionDate: date)
                }
            } else {
                return [FinancialEventOccurence(type: .transaction(txn))]
            }
        }
        
        let balanceResetOccurences = BalanceResetManager.shared.resets.flatMap { rst in
            return [FinancialEventOccurence(type: .reset(rst))]
        }
        
        allEvents = transactionOccurrences + balanceResetOccurences
    }
    
    
    private func sumOfAllTransactionsUpTo(_ date: Date) -> Double {
        allEvents
            .filter { $0.date <= date }
            .reduce(0) { $0 + $1.transaction!.amount }
    }
    
    
    private func compileGroupedEventList(from startDate: Date, to endDate: Date) -> [(key: Date, value: [FinancialEventOccurence])] {
        let calendar = Calendar.current

        // 4. Filter occurrences that lie within this shifted range
        let visibleOccurrences = allEvents.filter {
            $0.date >= startDate && $0.date <= endDate
        }

        // 5. Group by start of day
        let grouped = Dictionary(grouping: visibleOccurrences) { occ in
            calendar.startOfDay(for: occ.date)
        }

        // 6. Return them sorted by day
        return grouped
            .sorted { $0.key < $1.key }
    }
    
    
}
