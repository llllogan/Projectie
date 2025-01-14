//
//  AddTransaction.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 11/1/2025.
//

import SwiftUI
import SwiftData

struct AddTransactionSheet: View {
    
    @Environment(\.modelContext) private var context
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var transactionTitle: String = ""
    @State private var transactionNote: String = ""
    @State private var transactionAmount: String = ""
    @State private var isCredit = true
    @State private var selectedCategorySystemName: String?
    @State private var transactionDate = Date()
    
    @State private var showCategoryPicker = false
    @State private var showDatePicker = false
    
    @FocusState private var focusedField: Field?
    
    enum Field {
       case amount
       case title
       case note
   }
    
    func getCategory(by systemName: String) -> CategoryItem? {
        return categories.first { $0.systemName == systemName }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // ---- Amount Section ----
                Section(header: Text("Amount")) {
                    HStack(spacing: 8) {
                        Text(isCredit ? "$" : "-$")
                            .font(.system(size: 40, weight: .medium, design: .rounded))
                        
                        TextField("0.00", text: $transactionAmount)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 40, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.leading)
                            .focused($focusedField, equals: .amount)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                // ---- Details Section ----
                Section(header: Text("Descriptors")) {
                    TextField("Title", text: $transactionTitle)
                        .focused($focusedField, equals: .title)
                    TextEditor(text: $transactionNote)
                        .frame(minHeight: 100)
                        .focused($focusedField, equals: .note)
                }
                
                Section {
                    Button(action: {
                        isCredit.toggle()
                        hapticButtonPress()
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(isCredit ? "Credit" : "Debit")
                                Text(isCredit ? "Add money to the account" : "Remove money from the account")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: isCredit ? "tray.and.arrow.down" : "tray.and.arrow.up")
                                .font(.system(size: 25))
                        }
                        .frame(minHeight: 60)
                    }
                    
                    Button(action: {
                        showCategoryPicker.toggle()
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                if (selectedCategorySystemName != nil && getCategory(by: selectedCategorySystemName!) != nil) {
                                    Text(getCategory(by: selectedCategorySystemName!)!.name)
                                    Text("Transaction Category")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("Transaction Category")
                                }
                            }
                            Spacer()
                            Image(systemName: selectedCategorySystemName ?? "plus.square.dashed")
                                .font(.system(size: 30))
                        }
                        .frame(minHeight: 60)
                    }
                    .sheet(isPresented: $showCategoryPicker) {
                        CategoryPicker(
                            onSystemNameSelected: { category in
                                print("User selected: \(category)")
                                
                                if (category != "__nil_category__") {
                                    selectedCategorySystemName = category
                                } else {
                                    selectedCategorySystemName = nil
                                }
                            },
                            currentSelection: $selectedCategorySystemName
                        )
                    }
                }
                
                
                Section {
                    VStack {
                        DatePicker(
                            "Transaction Date/Time",
                            selection: $transactionDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.graphical)
                    }
                }
            }
            .navigationTitle("Add Transaction")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
        }
    }
    
    // Helper to format the date
    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func onCancel() {
        focusedField = nil
        dismiss()
    }
    
    private func onSave() {
        guard var amount = Double(transactionAmount) else {
            print("Invalid amount entered.")
            return
        }
        if (!isCredit) {
            amount *= -1
        }
        
        focusedField = nil
        
        
        let newTxn = Transaction(
            title: transactionTitle,
            amount: amount,
            isCredit: isCredit,
            date: transactionDate,
            note: transactionNote,
            categorySystemName: selectedCategorySystemName
        )
        
        print("Attempting to save transaction: \n\(newTxn.title)\n\(newTxn.amount)")
        
        do {
            context.insert(newTxn)
            try context.save()
            
            dismiss()
        } catch {
            print("Failed to save transaction to model: \(error)")
        }
    }
}


#Preview {
    AddTransactionSheet()
        .modelContainer(for: Transaction.self)
}
