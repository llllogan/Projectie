//
//  Goal.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 28/1/2025.
//

import SwiftData
import Foundation

@Model
final class Goal {
    var title: String
    var targetAmount: Double
    var account: Account
    
    // Optionally track when this goal was first created
    var createdDate: Date
    
    init(title: String, targetAmount: Double, account: Account, createdDate: Date = Date()) {
        self.title = title
        self.targetAmount = targetAmount
        self.account = account
        self.createdDate = createdDate
    }
    
    
    func earliestDateWhenGoalIsMet() -> Date? {
        let sortedOccurrences = FinancialEventManager.shared.allEvents.sorted(by: { $0.date < $1.date })
        
        let latestResetBeforeNow = BalanceResetManager.shared.resets.first(where: { $0.date <= Date() })
        
        var runningBalance: Double
        var lastResetDate: Date
        
        if let reset = latestResetBeforeNow {
            runningBalance = reset.balanceAtReset
            lastResetDate = reset.date
        } else {
            runningBalance = 0
            lastResetDate = .distantPast
        }
        
        let preNowOccurrences = sortedOccurrences.filter { $0.date > lastResetDate && $0.date <= Date() }
        for occ in preNowOccurrences {
            runningBalance += occ.transaction?.amount ?? 0
        }
        
        if runningBalance >= self.targetAmount {
            return Date()
        }
        
        let futureOccurrences = sortedOccurrences.filter { $0.date > Date() }
        
        for occ in futureOccurrences {
            runningBalance += occ.transaction?.amount ?? 0
            
            if runningBalance >= self.targetAmount {
                return occ.date
            }
        }
        
        return nil
    }

}
