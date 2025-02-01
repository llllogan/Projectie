//
//  TransactionListView.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 31/1/2025.
//

import SwiftUI
import Foundation

struct TransactionListView: View {
    
    var groupedOccurrences: [(key: Date, value: [TransactionOccurrence])]
    @Binding var activeSheet: ActiveSheet?
    
    var body: some View {
        
        List {
            ForEach(groupedOccurrences, id: \.key) { (date, occurrences) in
                Section(header: Text(date, style: .date)) {
                    transactionListDayOrganiser(occurenceList: occurrences, onTransactionSelected: { transaction in
                        activeSheet = .manageTransaction(transaction, date)
                    })
                }
            }
        }
        .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
    }
}

struct transactionListDayOrganiser: View {
    
    var occurenceList: [TransactionOccurrence]
    
    var onTransactionSelected: (Transaction) -> Void = { _ in }
    
    var body: some View {
        
        ForEach(occurenceList) { occ in
            
            switch occ.type {
            case .transaction(let txn):
                TransactionListElement(
                    transaction: txn,
                    overrideDate: occ.date
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    onTransactionSelected(occ.transaction!)
                }
            case .reset(let rst):
                BalanceResetListElement(reset: rst)
            }
            
        }
        
    }
}
