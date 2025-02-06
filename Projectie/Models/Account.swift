//
//  Account.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 6/2/2025.
//

import Foundation
import SwiftData

enum AccountType: String, CaseIterable {
    case saving = "Saving"
    case soending = "Spending"
}

enum InterestPaymentFrequency: Int, CaseIterable {
    case monthly = 1
    case quarterly = 3
    case annually = 12
}

@Model
class Account: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var type: AccountType
    var number: String
    var incurresInterest: Bool
    var interestRate: Double
    var interestPaymentFrequency: InterestPaymentFrequency
    
    init(
        name: String,
        type: AccountType,
        number: String? = nil,
        incurresInterest: Bool? = nil,
        interestRate: Double? = nil,
        interestPaymentFrequency: InterestPaymentFrequency? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.type = type
    }
}
