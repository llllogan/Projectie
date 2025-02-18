//
//  TransactionArchiver.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 18/2/2025.
//

import SwiftData
import Foundation

@ModelActor
actor TransactionArchiver {
    
    func archive() {
        
        let now = Date()
        let descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate{$0.isRecurring == true}
        )
        guard let transactions: [Transaction] = try? modelContext.fetch(descriptor) else { return }
        
        let filteredTransactions = transactions.filter { transaction in
            transaction.recurrenceDates.contains(where: { $0 < now })
        }
        
        for transaction in filteredTransactions {
            print(transaction.amount)
        }
        
        print("Found \(filteredTransactions.count) recurring transactions with dates in the past")
        
        
        
    }
}
