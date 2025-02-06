//
//  Account.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 6/2/2025.
//

import Foundation
import SwiftData

enum AccountType: String, Codable, CaseIterable, Identifiable {
    case saving = "Saving"
    case soending = "Spending"
    
    var id: Self { self }
}

enum InterestPaymentFrequency: String, Codable, CaseIterable, Identifiable {
    case monthly = "monthly"
    case quarterly = "quarterly"
    case annually = "annually"
    
    var id: Self { self }
}

@Model
class Account: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var type: AccountType
    var number: String?
    var incurresInterest: Bool?
    var interestRate: Double?
    var interestPaymentFrequency: InterestPaymentFrequency?
    
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
        
        self.number = number
        self.incurresInterest = incurresInterest
        self.interestRate = interestRate
        self.interestPaymentFrequency = interestPaymentFrequency
    }
}
