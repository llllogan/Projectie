//
//  TransactionList.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 15/1/2025.
//

import Foundation
import SwiftUI

struct TransactionList: View {
    
    var body: some View {
        List {
            ForEach(groupedOccurrences, id: \.key) { (date, occurrences) in
                Section(header: Text(date, style: .date)) {
                    ForEach(occurrences) { occ in
                        TransactionListElement(
                            transaction: occ.transaction,
                            overrideDate: occ.date // so we can see the exact date
                        )
                    }
                }
            }
        }
    }
}
