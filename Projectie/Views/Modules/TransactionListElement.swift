//
//  TransactionListElement.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 14/1/2025.
//

import SwiftUI

struct TransactionListElement: View {
    
    @State var transaction: Transaction
    var overrideDate: Date? = nil
    
    var lineThickness: CGFloat = 4
    var lineCornerRadius: CGFloat = 2
    
    var body: some View {
        
        let displayDate = overrideDate ?? transaction.date
        
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
                    Text("\(transaction.getCategory()?.name ?? "Unknown")")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                
                if (transaction.isRecurring) {
                    HStack(spacing: 3) {
                        Image(systemName: "clock.arrow.trianglehead.2.counterclockwise.rotate.90")
                            .font(.caption)
                            .fontWeight(.light)
                            .foregroundStyle(.secondary)
                        Text(getRecurrenceNoun(for: transaction))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("\(!transaction.isCredit ? "-" : "")$\(transaction.unsignedAmount, format: .number.precision(.fractionLength(2)))")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                Text("\(displayDate, format: .dateTime.hour().minute())")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

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
    
    
    func getRecurrenceNoun(for transaction: Transaction) -> String {
        
        if (!transaction.isRecurring) {
            return ""
        }
        
        if (transaction.recurrenceInterval == 1) {
            return transaction.recurrenceFrequency!.rawValue
        }
        
        if (transaction.recurrenceInterval == 2 && transaction.recurrenceFrequency == .weekly) {
            return "Fortnightly"
        }
        
        let pluralizedFrequency: String
        
        switch transaction.recurrenceFrequency! {
        case .daily:
            pluralizedFrequency = "days"
        case .weekly:
            pluralizedFrequency = "weeks"
        case .monthly:
            pluralizedFrequency = "months"
        case .yearly:
            pluralizedFrequency = "years"
        }
            
        return "Every \(transaction.recurrenceInterval) \(pluralizedFrequency)"
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

