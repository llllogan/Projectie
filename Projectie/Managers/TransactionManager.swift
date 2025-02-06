//
//  TransactionManager.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 6/2/2025.
//

import Foundation
import SwiftData
import Combine

final class TransactionManager: ObservableObject {
    /// Global shared instance.
    static let shared = TransactionManager()
    
    /// Holds the SwiftData model context.
    private var context: ModelContext?
    
    /// Private initializer to enforce singleton usage.
    private init() { }
    
    @Published private var transactionListMinus2: [(key: Date, value: [TransactionOccurrence])]?
    @Published private var transactionListMinus1: [(key: Date, value: [TransactionOccurrence])]?
    @Published private var transactionListToday: [(key: Date, value: [TransactionOccurrence])]?
    @Published private var transactionListPlus1: [(key: Date, value: [TransactionOccurrence])]?
    @Published private var transactionListPlus2: [(key: Date, value: [TransactionOccurrence])]?
    
    /// Computed property returning transactions for the selected account.
    var transactions: [Transaction] {
        guard let context = context else {
            print("ModelContext has not been set for TransactionManager.")
            return []
        }
        
        // Ensure we have a selected account.
        guard let selectedAccount = AccountManager.shared.selectedAccount else {
            print("No account selected.")
            return []
        }
        
        let accountID: UUID = selectedAccount.id
        
        // Build a predicate that filters transactions for the selected account.
        let predicate = #Predicate<Transaction> { transaction in
            transaction.account.id == accountID
        }
        
        let fetchDescriptor = FetchDescriptor<Transaction>(predicate: predicate)
        do {
            return try context.fetch(fetchDescriptor)
        } catch {
            print("Error fetching transactions: \(error)")
            return []
        }
    }
    
    /// Set the model context when available.
    func setContext(_ context: ModelContext) {
        self.context = context
    }
    
    /// You can add other computed properties or functions here based on transactions.
    func totalAmount() -> Double {
        transactions.reduce(0) { $0 + $1.amount }
    }
    
    func groupedOccurrences(startDate: Date, endDate: Date) -> [(key: Date, value: [TransactionOccurrence])] {
        let calendar = Calendar.current

        // 4. Filter occurrences that lie within this shifted range
        let visibleOccurrences = transactions.filter {
            $0.date >= startDate && $0.date <= endDate
        }

        // 5. Group by start of day
        let grouped = Dictionary(grouping: visibleOccurrences) { occ in
            calendar.startOfDay(for: occ.date)
        }

        // 6. Return them sorted by day
        
    }

}

