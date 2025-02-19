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
            transaction.recurrenceDates.contains(where: { $0 < now }) && (transaction.isArchived == false || transaction.isArchived == nil)
        }
        
        print("Found \(filteredTransactions.count) recurring transactions with dates in the past")
        
        for transaction in filteredTransactions {
            
            print(transaction.title)
            
            let instancesToArchive: [Date] = transaction.recurrenceDates.filter { $0 < now }
            
            for instance in instancesToArchive {
                
                print("Archiving transaction for instance: \(instance)")
                addArchivedTransaction(transaction, instance)
                
            }
        }
        
    }
    
    
    private func addArchivedTransaction(_ transaction: Transaction, _ instance: Date) {
        
        if let index = transaction.recurrenceDates.firstIndex(of: instance) {
            transaction.recurrenceDates.remove(at: index)
        } else {
            print("Instance date not found in recurrenceDates.")
        }
        
        modelContext.insert(Transaction(
            title: transaction.title,
            amount: transaction.amount,
            isCredit: transaction.isCredit,
            date: instance,
            account: transaction.account,
            note: transaction.note,
            categorySystemName: transaction.categorySystemName,
            isRecurring: true,
            recurrenceFrequency: transaction.recurrenceFrequency,
            recurrenceInterval: transaction.recurrenceInterval,
            recurrenceDates: [instance],
            isArchived: true)
        )
        
        try? modelContext.save()
    }
    
    
}
