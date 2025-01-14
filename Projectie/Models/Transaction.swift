//
//  Transaction.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 10/1/2025.
//

import SwiftData
import Foundation

@Model
class Transaction: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var amount: Double
    var isCredit: Bool
    var date: Date
    var note: String?
    var categorySystemName: String?
    
    init(
        title: String,
        amount: Double,
        isCredit: Bool,
        date: Date,
        note: String? = nil,
        categorySystemName: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.amount = amount
        self.isCredit = isCredit
        self.date = date
        self.note = note
        self.categorySystemName = categorySystemName
    }
    
    func getCategory() -> CategoryItem? {
        return categories.first { $0.systemName == categorySystemName }
    }

}
