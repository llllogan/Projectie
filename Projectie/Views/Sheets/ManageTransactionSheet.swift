//
//  ManageTransactionSheet.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 20/1/2025.
//

import SwiftUI
import SwiftData

struct ManageTransactionSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var showDeleteOptions = false
    @State private var showEditTransactionAlert = false
    
    @State private var testFieldString: String = ""
    
    @FocusState private var focusedField: Field?
    
    @State var transaction: Transaction
    @State var instanceDate: Date
    
    

    var body: some View {
        
        let categoryImageName = transaction.categorySystemName
        
        NavigationView {
            VStack {
                
                Image(systemName: categoryImageName)
                    .foregroundStyle(transaction.getCategory()?.color ?? .secondary)
                    .font(.largeTitle)
                
                
                Text(transaction.title)
                    .font(.largeTitle)
                    .padding(.top)
                
                Text("\(transaction.isCredit ? "" : "-")$\(transaction.unsignedAmount, format: .number.precision(.fractionLength(2)))")
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
                .padding(.bottom, 40)
                
                TextField("Description", text: $testFieldString)
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    

                Spacer()
                
                VStack(spacing: 10) {
                    Button(action: {
                        showEditTransactionAlert = true
                    }) {
                        Text("Edit")
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)
                    .buttonStyle(.bordered)
                    .tint(Color.primary)

                    
                    Button(action: {
                        showDeleteOptions = true
                    }) {
                        Text("Deleting Options")
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)
                    .buttonStyle(.bordered)
                    .tint(Color.red)
                    .padding(.bottom)
                }
                
            }
            .padding(.top, 60)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
            .sheet(isPresented: $showDeleteOptions) {
                DeleteTransactionSheet { selectedOption in
                    print(selectedOption)
                    showDeleteOptions = false
                    handleDeleteTransaction(with: selectedOption)
                }
                .presentationDetents(.init([.fraction(0.6)]))
                .presentationDragIndicator(.visible)
            }
            .alert("Woah There", isPresented: $showEditTransactionAlert) {
                Button("OK", role: .cancel) {
                    showEditTransactionAlert = false
                }
            } message: {
                Text("You can only edit the note of this transaction. Do that by tapping in the note form, then click done. \n\nPlease let me know which aspect of the transaction you would like to edit and I will look to impliment that.")
            }
        }
    }
    
    
    private func handleDeleteTransaction(with choice: TransactionDeleteChoice) {
        switch choice {
        case .all:
            deleteAllOccurrences()
        case .thisOne:
            deleteJustThisOne()
        case .future:
            deleteFutureOccurrences()
        }
        dismiss()
    }
    
    private func deleteAllOccurrences() {
        context.delete(transaction)
        try? context.save()
    }
    
    private func deleteJustThisOne() {
        if let index = transaction.recurrenceDates.firstIndex(of: instanceDate) {
            transaction.recurrenceDates.remove(at: index)
            
            try? context.save()
        } else {
            print("Instance date not found in recurrenceDates.")
        }
    }
    
    private func deleteFutureOccurrences() {
        transaction.recurrenceDates = transaction.recurrenceDates.filter { $0 < instanceDate }
        
        // Save the updated transaction
        try? context.save()
    }
    
    
    
    private func getRecurrenceDescription() -> String {
        
        if (transaction.recurrenceInterval == 1) {
            switch transaction.recurrenceFrequency {
                case .daily:
                    return "Daily"
                case .weekly:
                    return "Weekly"
                case .monthly:
                    return "Monthly"
                case .yearly:
                    return "Annually"
            case .none:
                return ""
            }
        }
        
        if (transaction.recurrenceInterval == 2 && transaction.recurrenceFrequency == .weekly) {
            return "Fortnightly"
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
    
    
    enum Field {
        case amount
        case title
        case note
        case occurences
        case notes
    }

}


#Preview {
    ManageTransactionSheet(
        transaction: Transaction(
            title: "Test",
            amount: 9.0,
            isCredit: true,
            date: Date(),
            account: Account(name: "Test", type: .saving),
            categorySystemName: "circle.dashed"
        ),
        instanceDate: Date()
    )
}
