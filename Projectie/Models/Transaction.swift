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
    var title: String
    var amount: Double
    var date: Date
    var note: String?
    var category: Category?
    
    init(
        title: String,
        amount: Double,
        date: Date = Date(),
        note: String? = nil,
        category: Category? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.amount = amount
        self.date = date
        self.note = note
        self.category = category
    }
}
