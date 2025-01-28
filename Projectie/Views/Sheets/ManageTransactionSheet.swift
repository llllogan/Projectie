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
    
    @State private var transactionNote: String = "__init__"
    @State private var leadingToolbarNoun: String = "Cancel"
    
    @State private var isSaving: Bool = false
    
    @State private var showDeleteOptions = false
    @State private var showEditTransactionAlert = false
    
    @FocusState private var focusedField: Field?
    
    
    var transaction: Transaction
    var instanceDate: Date
    
    init (transaction: Transaction, instanceDate: Date? = nil) {
        self.transaction = transaction
        self.instanceDate = instanceDate ?? transaction.date
        
        print(self.instanceDate)
    }
    
    private var debouncer = TransactionNoteAutoSaveTimer(interval: 0.5)
    
    
    var body: some View {
        
        NavigationView {
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
                        header: HStack {
                            Text("Notes")
                            Image(systemName: "progress.indicator")
                                .symbolEffect(
                                    .variableColor.iterative.dimInactiveLayers.nonReversing,
                                    options: .repeat(.continuous)
                                )
                                .opacity(isSaving ? 1 : 0)
                        }
                    ) {
                        TextField("Notes", text: $transactionNote)
                            .focused($focusedField, equals: .notes)
                            .onAppear {
                                transactionNote = transaction.note ?? ""
                            }
                            .frame(minHeight: 100, alignment: .top)
                            .onChange(of: transactionNote) { oldValue, newValue in
                                debouncer.call {
                                    if checkForDifferences(for: oldValue, and: newValue) {
                                        print("saving")
                                        transaction.note = newValue
                                        try? context.save()
                                        leadingToolbarNoun = "Done"
                                    }
                                }
                            }
                    }
                }
                .frame(minHeight: 200)
                .scrollDisabled(true)
                
                
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
            .padding(.top, 20)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text(leadingToolbarNoun)
                    }
                    .buttonStyle(.plain)
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
            .alert("Woah There!", isPresented: $showEditTransactionAlert) {
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
    
    private func checkForDifferences(for oldNote: String, and newNote: String) -> Bool {
        
        if (oldNote == "__init__") {
            return false
        }
        
        if (oldNote != newNote) {
            return true
        }
        
        return false
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
    
    let transaction: Transaction = Transaction (
        title: "Shopping", amount: 24.56, isCredit: false, date: Date(), note: "", categorySystemName: "cart.fill", isRecurring: false)

    ManageTransactionSheet(transaction: transaction)
}
