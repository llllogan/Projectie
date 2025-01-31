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
        .safeAreaPadding(.bottom, 40)
    }
}
