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
    var note: String?
    var categorySystemName: String?
    
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
        note: String? = nil,
        categorySystemName: String? = nil,
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

}
