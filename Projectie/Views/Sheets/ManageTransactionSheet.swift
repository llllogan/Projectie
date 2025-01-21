//
//  ManageTransactionSheet.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 20/1/2025.
//

import SwiftUI
import SwiftData

struct ManageTransactionSheet: View {
    
    var transaction: Transaction
    
    @State private var transactionNote: String = ""
    @State private var isSaving: Bool = false
    
    
    var body: some View {
        
        VStack(alignment: .center) {
            
            Image(systemName: transaction.categorySystemName!)
                .foregroundStyle(transaction.getCategory()?.color ?? .secondary)
                .font(.largeTitle)
            
            
            Text(transaction.title)
                .font(.largeTitle)
                .padding(.top)
            
            Text("\(!transaction.isCredit ? "-" : "")$\(transaction.unsignedAmount, format: .number.precision(.fractionLength(2)))")
                .font(.system(size: 45, weight: .bold, design: .rounded))
                .padding(.bottom, 8)
                
            
            HStack(alignment: .top) {
                
                VStack (alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "clock")
                        Text("\(transaction.date, format: .dateTime.minute().hour())")
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                        Text("\(transaction.date, format: .dateTime.day().month().year())")
                    }

                }
                .frame(maxWidth: .infinity)
                
                VStack (alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "tray.full")
                        Text(transaction.getCategory()?.name ?? "Unknown")
                    }
                    HStack {
                        
                        if transaction.isRecurring {
                            Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                            Text(getRecurrenceDescription())
                        } else {
                            Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                                .foregroundStyle(.secondary)
                            Text("Not recurring")
                                .foregroundStyle(.secondary)
                        }
                                               
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)

            
            
            Form {
                Section(
                    header: Text("Notes"),
                    footer: Label(
                        isSaving ? "Saving" : "",
                        systemImage: isSaving ? "progress.indicator" : "")
                        .symbolEffect(
                            .variableColor.iterative.dimInactiveLayers.nonReversing,
                            options: .repeat(.continuous)
                        )
                ) {
                    TextField("Notes", text: $transactionNote)
                        .onAppear {
                            transactionNote = transaction.note ?? ""
                        }
                        .frame(minHeight: 100, alignment: .top)
                }
            }
            
            
            VStack(spacing: 10) {
                Button(action: {
                    
                }) {
                    Text("Edit")
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                .buttonStyle(.bordered)

                
                Button(action: {
                    
                }) {
                    Text("Delete...")
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                .buttonStyle(.borderedProminent)
                .tint(Color.red)
                .padding(.bottom)
            }
            
        }
        .padding(.top)
    }
    
    
    private func getRecurrenceDescription() -> String {
        
        if (transaction.recurrenceInterval == 1) {
            switch transaction.recurrenceFrequency {
                case .daily:
                    return "Day"
                case .weekly:
                    return "Week"
                case .monthly:
                    return "Month"
                case .yearly:
                    return "Year"
            case .none:
                return ""
            }
        }
        
        switch transaction.recurrenceFrequency {
        case .daily:
            return "\(transaction.recurrenceInterval) Days"
        case .weekly:
            return "\(transaction.recurrenceInterval) Weeks"
        case .monthly:
            return "\(transaction.recurrenceInterval) Months"
        case .yearly:
            return "\(transaction.recurrenceInterval) Years"
        case .none:
            return ""
        }
        
    }

}

#Preview {
    
    let transaction: Transaction = Transaction (
        title: "Shopping", amount: 24.56, isCredit: false, date: Date(), note: "", categorySystemName: "cart.fill", isRecurring: false)

    ManageTransactionSheet(transaction: transaction)
}
