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
    
    
    @State private var isRecurring: Bool = false
    @State private var recurrenceFrequency: RecurrenceFrequency = .weekly
    @State private var recurrenceInterval: Int = 1
    
    // Optional End Conditions
    @State private var endDate: Date = Date()
    @State private var useEndDate: Bool = false
    
    @State private var useOccurrenceCount: Bool = false
    @State private var occurrenceCount: String = ""
    
    
    @State private var showCategoryPicker = false
    @FocusState private var focusedField: Field?
    
    enum Field {
       case amount
       case title
       case note
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
                    
                    TransactionPresetTickers { preset in
                        populatePreset(with: preset)
                    }
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
                    
                    DatePicker(
                        "Transaction Date/Time",
                        selection: $transactionDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                    
                    Toggle("Recurring Transaction", isOn: $isRecurring)
                    
                    if isRecurring {
                        // If recurring, show frequency & interval
                        Picker("Frequency", selection: $recurrenceFrequency) {
                            ForEach(RecurrenceFrequency.allCases) { freq in
                                Text(freq.rawValue).tag(freq)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        Stepper("Every \(recurrenceInterval) \(recurrenceFrequency.rawValue)",
                                value: $recurrenceInterval,
                                in: 1...30)
                        
                        Toggle("End by Date", isOn: $useEndDate)
                        if useEndDate {
                            DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                        }
                        
                        Toggle("End by Occurrence Count", isOn: $useOccurrenceCount)
                        if useOccurrenceCount {
                            TextField("Max Occurrences", text: $occurrenceCount)
                                .keyboardType(.numberPad)
                        }
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
    
    
    
    
    private func getCategory(by systemName: String) -> CategoryItem? {
        return categories.first { $0.systemName == systemName }
    }
    
    private func populatePreset(with preset: TransactionPreset) {
        transactionTitle = preset.title
        transactionNote = preset.note
        isCredit = preset.isCredit
        selectedCategorySystemName = preset.category.systemName
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
        
        let dateArray: [Date]
        
        if isRecurring {
            // We'll compute a recurrence array from transactionDate (start), but user might not see a date picker.
            // Let's use transactionDate as a "start date" or just default to now if needed.
            let start = transactionDate
            
            // End conditions
            let limitDate = useEndDate ? endDate : nil
            let maxCount = useOccurrenceCount ? Int(occurrenceCount) : nil
            
            // Actually compute the array of dates
            // If the user never selected transactionDate for start (since we hid the DatePicker),
            // you could present a separate "Start Date" pick or just assume "now".
            dateArray = computeRecurrenceDates(
                startDate: start,
                frequency: recurrenceFrequency,
                interval: recurrenceInterval,
                maxOccurrences: maxCount,
                endDate: limitDate
            )
            
            // If dateArray is empty for some reason, you might decide how to handle that.
            
        } else {
            // Not recurring => just store the single chosen transactionDate
            dateArray = [transactionDate]
        }
        
        
        let newTxn = Transaction(
            title: transactionTitle,
            amount: amount,
            isCredit: isCredit,
            date: transactionDate,  // single "main" date, might not matter if recurring
            note: transactionNote,
            categorySystemName: selectedCategorySystemName,
            isRecurring: isRecurring,
            recurrenceFrequency: isRecurring ? recurrenceFrequency : nil,
            recurrenceInterval: recurrenceInterval,
            recurrenceDates: dateArray
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
