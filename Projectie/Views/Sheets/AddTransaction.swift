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
    @State private var selectedCategory: Category?
    @State private var transactionDate = Date()
    
    @State private var categories: [Category] = [
        Category(title: "Groceries", systemName: "cart.fill"),
        Category(title: "Utilities", systemName: "lightbulb"),
        Category(title: "Rent", systemName: "house.fill")
    ]
    
    // 2) For demonstration, we’ll track whether we show pickers
    @State private var showCategoryPicker = false
    @State private var showDatePicker = false
    
    var onSave: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                // ---- Amount Section ----
                Section(header: Text("Amount")) {
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
                Section(header: Text("Details")) {
                    TextField("Note", text: $transactionNote)
                }
                
                // ---- New Section with 3 buttons horizontally ----
                Section {
                    HStack(spacing: 8) {
                        // 1) Left button: toggles between Credit and Debit
                        Button {
                            isCredit.toggle()
                        } label: {
                            Text(isCredit ? "Credit" : "Debit")
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, minHeight: 90)
                                .background(Color.white)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        
                        // 2) Center button: pick a Category
                        Button {
                            showCategoryPicker.toggle()
                        } label: {
                            Text(selectedCategory?.title ?? "Uncategorized")
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, minHeight: 90)
                                .background(Color.white)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        .sheet(isPresented: $showCategoryPicker) {
                            CategoryPicker(categories: categories) { chosenCategory in
                                selectedCategory = chosenCategory
                            }
                        }
                        
                        // 3) Right button: pick Date/Time
                        Button {
                            showDatePicker.toggle()
                        } label: {
                            Text(dateString(transactionDate))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, minHeight: 90)
                                .background(Color.white)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        .sheet(isPresented: $showDatePicker) {
                            DateTimePickerView(selectedDate: $transactionDate)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .listRowBackground(Color.clear)
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
