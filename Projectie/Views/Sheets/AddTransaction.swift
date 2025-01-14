//
//  AddTransaction.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 11/1/2025.
//

import SwiftUI

struct AddTransactionSheet: View {
    @Binding var transactionNote: String
    @Binding var transactionAmount: String
    
    // 1) New @State properties for credit/debit toggle, category, and date
    @State private var isCredit = true
    @State private var selectedCategory: String?
    @State private var transactionDate = Date()
    @State private var transactionTitle: String = ""
    
    // 2) For demonstration, we’ll track whether we show pickers
    @State private var showCategoryPicker = false
    @State private var showDatePicker = false
    
    var onSave: () -> Void
    var onCancel: () -> Void
    
    func getCategory(by systemName: String) -> CategoryItem? {
        return categories.first { $0.systemName == systemName }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // ---- Amount Section ----
                Section(header: Text("")) {
                    HStack(spacing: 8) {
                        Text("$")
                            .font(.system(size: 40, weight: .medium, design: .rounded))
                        
                        TextField("0.00", text: $transactionAmount)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 40, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                // ---- Details Section ----
                Section {
                    TextField("Title", text: $transactionTitle)
                    TextEditor(text: $transactionNote)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Button(action: {
                        isCredit.toggle()
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
                                if (selectedCategory != nil && getCategory(by: selectedCategory!) != nil) {
                                    Text(getCategory(by: selectedCategory!)!.name)
                                    Text("Transaction Category")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("Transaction Category")
                                }
                            }
                            Spacer()
                            Image(systemName: selectedCategory ?? "plus.square.dashed")
                                .font(.system(size: 30))
                        }
                        .frame(minHeight: 60)
                    }
                    .sheet(isPresented: $showCategoryPicker) {
                        CategoryPicker { category in
                            print("User selected: \(category)")
                            selectedCategory = category
                        }
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
}



// MARK: - Example Date/Time Picker View

struct DateTimePickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedDate: Date
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Transaction Date/Time",
                    selection: $selectedDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Pick Date/Time")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var transactionNote = "Preview Note"
        @State private var transactionAmount = "100.00"
        
        var body: some View {
            AddTransactionSheet(
                transactionNote: $transactionNote,
                transactionAmount: $transactionAmount,
                onSave: {},
                onCancel: {}
            )
        }
    }
    
    return PreviewWrapper()
}
