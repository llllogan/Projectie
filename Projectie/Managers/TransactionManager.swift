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
    
    @Published var transactions: [Transaction] = []
    
    func setTransactions(_ transactions: [Transaction]) {
        
        guard let selectedAccount = AccountManager.shared.selectedAccount else {
            print("No account selected.")
            self.transactions = []
            return
        }
        
        let accountID: UUID = selectedAccount.id
        
        let relevantTransactions: [Transaction] = transactions.filter { transaction in
            transaction.account.id == accountID
        }
        
        self.transactions = relevantTransactions
    }
}

