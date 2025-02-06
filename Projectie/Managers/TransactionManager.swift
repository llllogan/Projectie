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
    
    /// Set the model context when available.
    func setContext(_ context: ModelContext) {
        self.context = context
    }
    
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
    
    /// You can add other computed properties or functions here based on transactions.
    func totalAmount() -> Double {
        transactions.reduce(0) { $0 + $1.amount }
    }
}
