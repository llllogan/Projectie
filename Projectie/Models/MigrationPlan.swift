//
//  MigrationPlan.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 18/2/2025.
//

import SwiftData
import Foundation

enum carrotSchemaV1: VersionedSchema {
    
    static var models: [any PersistentModel.Type] {
        [Transaction.self, BalanceReset.self, Goal.self, Account.self]
    }
    
    static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)

    @Model
    final class Transaction: Identifiable {
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
        
        var unsignedAmount: Double { amount.sign == .minus ? -amount : amount }
        
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
    
    @Model
    class BalanceReset {
        @Attribute(.unique) var id: UUID
        var date: Date
        var balanceAtReset: Double
        var account: Account
        var isStartingBalance: Bool

        init(date: Date, balanceAtReset: Double, account: Account, isStartingBalance: Bool = false) {
            self.id = UUID()
            self.date = date
            self.balanceAtReset = balanceAtReset
            self.account = account
            self.isStartingBalance = isStartingBalance
        }
    }
    
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
    
    
}

enum carrotSchemaV2: VersionedSchema {
    
    static var models: [any PersistentModel.Type] {
        [Transaction.self, BalanceReset.self, Goal.self, Account.self]
    }
    
    static var versionIdentifier: Schema.Version = Schema.Version(1, 1, 0)
    
    @Model
    final class Transaction: Identifiable {
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
        
        var isArchived: Bool?
        
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
            recurrenceDates: [Date] = [],
            isArchived: Bool? = false
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
            self.isArchived = isArchived
        }
        
        func getCategory() -> CategoryItem? {
            return categories.first { $0.systemName == categorySystemName }
        }
        
        var unsignedAmount: Double { amount.sign == .minus ? -amount : amount }
        
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
    
    @Model
    class BalanceReset {
        @Attribute(.unique) var id: UUID
        var date: Date
        var balanceAtReset: Double
        var account: Account
        var isStartingBalance: Bool

        init(date: Date, balanceAtReset: Double, account: Account, isStartingBalance: Bool = false) {
            self.id = UUID()
            self.date = date
            self.balanceAtReset = balanceAtReset
            self.account = account
            self.isStartingBalance = isStartingBalance
        }
    }
    
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

    
}


enum CarrotMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [carrotSchemaV1.self, carrotSchemaV2.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    
    static let migrateV1toV2 = MigrationStage.lightweight(fromVersion: carrotSchemaV1.self, toVersion: carrotSchemaV2.self)
}
