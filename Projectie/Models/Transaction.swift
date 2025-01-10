//
//  Transaction.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 10/1/2025.
//

import SwiftData
import Foundation

@Model
class Transaction {
    @Attribute(.unique) var id: UUID
    var amount: Double    // Positive for credit, negative for debit
    var date: Date
    var note: String?

    init(amount: Double, date: Date = Date(), note: String? = nil) {
        self.id = UUID()
        self.amount = amount
        self.date = date
        self.note = note
    }
}
