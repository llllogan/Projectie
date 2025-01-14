//
//  TransactionListElement.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 14/1/2025.
//

import SwiftUI

struct TransactionListElement: View {
    
    @State var transaction: Transaction
    
    var lineThickness: CGFloat = 4
    var lineCornerRadius: CGFloat = 2
    
    var body: some View {
        
        HStack {
            RoundedRectangle(cornerRadius: lineCornerRadius)
                .fill(transaction.getCategory()?.color ?? Color.gray)
                .frame(width: lineThickness)
                .frame(maxHeight: .infinity)
                .padding(.trailing, 7)
            
            VStack(alignment: .leading) {
                Text(transaction.title)
                    .font(.headline)
                HStack(spacing: 3) {
                    Image(systemName: removeFillModifier(from: transaction.categorySystemName!))
                        .font(.caption)
                        .fontWeight(.light)
                        .foregroundStyle(.secondary)
                    Text("\(transaction.getCategory()?.name ?? "Unknown"), \(transaction.date, format: .dateTime.hour().minute().second())")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                }
            }
            Spacer()
            HStack {
                Text("\(!transaction.isCredit ? "-" : "")$\(transaction.amount, format: .number.precision(.fractionLength(2)))")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
            }
        }
    }
    
    func removeFillModifier(from systemName: String) -> String {
        let fillSuffix = ".fill"
        
        
        if systemName.hasSuffix(fillSuffix) {
            let endIndex = systemName.index(systemName.endIndex, offsetBy: -fillSuffix.count)
            let modifiedName = String(systemName[..<endIndex])
            return modifiedName
        } else {
            return systemName
        }
    }
}

#Preview {
    
    let transactions: [Transaction] = [
        Transaction(
            title: "Test",
            amount: 1000,
            isCredit: false,
            date: Date(),
            note: "Hello",
            categorySystemName: "house.fill"
        ),
        Transaction(
            title: "Test",
            amount: 1000,
            isCredit: true,
            date: Date(),
            note: "Hello",
            categorySystemName: "gift.fill"
        )
    ]
    
    List(transactions) { transaction in
        TransactionListElement(transaction: transaction)
    }
}

