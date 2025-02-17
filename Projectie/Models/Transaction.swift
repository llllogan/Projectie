//
//  Transaction.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 10/1/2025.
//

import SwiftData
import Foundation

enum RecurrenceFrequency: String, Codable, CaseIterable, Identifiable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    
    var id: Self { self }
}

@Model
class Transaction: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var amount: Double
    var isCredit: Bool
    var date: Date
    var account: Account
    var note: String?
    var categorySystemName: String
    
    var isRecurring: Bool
        
    var recurrenceFrequency: RecurrenceFrequency?
    var recurrenceInterval: Int
    var recurrenceDates: [Date]
    

    var unsignedAmount: Double { amount.sign == .minus ? -amount : amount }
    
    init(
        title: String,
        amount: Double,
        isCredit: Bool,
        date: Date,
        account: Account,
        note: String? = nil,
        categorySystemName: String,
        isRecurring: Bool = false,
        recurrenceFrequency: RecurrenceFrequency? = nil,
        recurrenceInterval: Int = 1,
        recurrenceDates: [Date] = []
    ) {
        self.id = UUID()
        self.title = title
        self.amount = amount
        self.isCredit = isCredit
        self.date = date
        self.account = account
        self.note = note
        self.categorySystemName = categorySystemName
        
        self.isRecurring = isRecurring
        self.recurrenceFrequency = recurrenceFrequency
        self.recurrenceInterval = recurrenceInterval
        self.recurrenceDates = recurrenceDates
    }
    
    func getCategory() -> CategoryItem? {
        return categories.first { $0.systemName == categorySystemName }
    }
    
    var reoccurancesPerYear: Double {
        switch recurrenceFrequency {
        case .yearly:
            return 1 / Double(recurrenceInterval)
        case .monthly:
            return 12 / Double(recurrenceInterval)
        case .weekly:
            return 52 / Double(recurrenceInterval)
        case .daily:
            return 365 / Double(recurrenceInterval)
        default:
            return 0
        }
    }
    
    
    var pricePerWeek: Double {
        return abs((amount * reoccurancesPerYear) / 52)
    }
    
    var pricePerMonth: Double {
        return abs((amount * reoccurancesPerYear) / 12)
    }
    
    var pricePerDay: Double {
        return abs((amount * reoccurancesPerYear) / 365)
    }

}

enum TransactionDeleteChoice: String {
    case all = "all"
    case thisOne = "thisOne"
    case future = "future"
}
