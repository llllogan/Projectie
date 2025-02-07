//
//  TransactionOccurence.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 3/2/2025.
//

import Foundation

struct FinancialEventOccurence: Identifiable {
    
    let type: EventType
    let recurringTransactionDate: Date?
    
    init(type: EventType, recurringTransactionDate: Date? = nil) {
        self.type = type
        self.recurringTransactionDate = recurringTransactionDate
    }
    
    var transaction: Transaction? {
        switch type {
        case .transaction(let transaction):
            return transaction
        default:
            return nil
        }
    }
    
    var date: Date {
        switch type {
        case .transaction(let transaction):
            return recurringTransactionDate ?? transaction.date
        case .reset(let balanceReset):
            return balanceReset.date
        }
    }
    
    var id: String {
        switch type {
        case .transaction(let transaction):
            return "\(transaction.id)-\(date.timeIntervalSince1970)"
        case .reset(let balanceReset):
            return "\(balanceReset.id)-\(date.timeIntervalSince1970)"
        }

    }
}

enum EventType {
    case transaction(Transaction)
    case reset(BalanceReset)
}
