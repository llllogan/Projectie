//
//  TransactionListView.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 31/1/2025.
//

import SwiftUI
import Foundation

struct TransactionListView: View {
    
    var groupedOccurrences: [(key: Date, value: [FinancialEventOccurence])]

    var body: some View {
        
        if(groupedOccurrences.isEmpty) {
            VStack {
                Spacer()
                Text("No transactions for this \(TimeManager.shared.timePeriod.rawValue)")
                    .foregroundStyle(.secondary)
                    .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                Spacer()
            }
        } else {
            
            List {
                ForEach(groupedOccurrences, id: \.key) { (date, occurrences) in
                    Section(header: Text(date, format: .dateTime.weekday(.wide).day().month(.wide))) {
                        transactionListDayOrganiser(occurenceList: occurrences)
                    }
                }
            }
            .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
            .defaultScrollAnchor(.top)
        }
    }
}

struct transactionListDayOrganiser: View {
    
    var occurenceList: [FinancialEventOccurence]
    
    var body: some View {
        
        ForEach(occurenceList) { occ in
            
            switch occ.type {
            case .transaction(let txn):
                TransactionListElement(
                    transaction: txn,
                    overrideDate: occ.date
                )
            case .reset(let rst):
                BalanceResetListElement(reset: rst)
            }
            
        }
        
    }
}
