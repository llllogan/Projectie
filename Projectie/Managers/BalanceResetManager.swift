//
//  BalanceResetManager.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 7/2/2025.
//

import Foundation
import SwiftData
import Combine

final class BalanceResetManager: ObservableObject {
    /// Global shared instance.
    static let shared = BalanceResetManager()
    
    /// Holds the SwiftData model context.
    private var context: ModelContext?
    
    /// Private initializer to enforce singleton usage.
    private init() { }
    
    /// Computed property returning transactions for the selected account.
    var resets: [BalanceReset] {
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
        let predicate = #Predicate<BalanceReset> { reset in
            reset.account.id == accountID
        }
        
        let fetchDescriptor = FetchDescriptor<BalanceReset>(predicate: predicate)
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

}
