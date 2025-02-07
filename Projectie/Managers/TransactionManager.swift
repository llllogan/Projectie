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
    
    static let shared = TransactionManager()
    
    private var context: ModelContext?
    
    private init() { }
    
    @Published var centeredTransactionViewId: Int? = nil
    @Published var ignoreChangeInCenteredTransactionViewId: Bool = false
    
    
    var transactions: [Transaction] {
        guard let context = context else {
            print("ModelContext has not been set for TransactionManager.")
            return []
        }
        
        guard let selectedAccount = AccountManager.shared.selectedAccount else {
            print("No account selected.")
            return []
        }
        
        let accountID: UUID = selectedAccount.id
        
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
    
    
    func setContext(_ context: ModelContext) {
        self.context = context
    }
}

