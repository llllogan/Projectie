//
//  AddTransaction.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 11/1/2025.
//

import SwiftUI
import SwiftData

struct OnEditConfirmOptions: Identifiable {
    let id = UUID()
    let datesPreceeding: [Date]
}

struct ManageTransactionSheet: View {
    
    @Environment(\.modelContext) private var context
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var transactionTitle: String = ""
    @State private var transactionNote: String = ""
    @State private var transactionAmount: String = ""
    @State private var isCredit = true
    @State private var selectedCategorySystemName: String?
    @State private var transactionDate: Date
    
    
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
    
    @State private var showErrorAlert = false
    
    @State private var editMode = false
    
    @State private var originalTransaction: Transaction?
    @State private var initialInstanceDate: Date?
    @State private var isArchived: Bool = false
    
    @State private var showEditTypeDesicionDialog: Bool = false
    @State private var editConfirmOptions: OnEditConfirmOptions = .init(datesPreceeding: [])
    
    
    // MARK: - Control Flag
    @State private var lockChangeToRecurrance: Bool = false
    @State private var defaultToEditAll: Bool = false
    @State private var defaultToEditForwards: Bool = false
    
    
    enum Field {
        case amount
        case title
        case note
        case occurences
   }
    
    init(transaction: Transaction? = nil, instanceDate: Date? = nil) {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        
        if let midnight = calendar.date(from: components) {
            _transactionDate = State(initialValue: midnight)
        } else {
            _transactionDate = State(initialValue: now)
        }
        
        if let transaction = transaction {
            
            _originalTransaction = State(initialValue: transaction)
            
            _editMode = State(initialValue: true)
            
            _transactionTitle = State(initialValue: transaction.title)
            _transactionDate = State(initialValue: instanceDate!)
            _initialInstanceDate = State(initialValue: instanceDate!)
            _transactionNote = State(initialValue: transaction.note ?? "")
            _transactionAmount = State(initialValue: String(transaction.unsignedAmount))
            
            _isCredit = State(initialValue: transaction.isCredit)
            _selectedCategorySystemName = State(initialValue: transaction.categorySystemName)
            
            if transaction.isRecurring {
                _isRecurring = State(initialValue: transaction.isRecurring)
                _recurrenceFrequency = State(initialValue: transaction.recurrenceFrequency!)
                _recurrenceInterval = State(initialValue: transaction.recurrenceInterval)
                
                _initialInstanceDate = State(initialValue: instanceDate)
            }
            
            var isArchiverd: Bool = false
            
            if transaction.isArchived != nil {
                isArchiverd = transaction.isArchived!
            }
            
            if isArchiverd && transaction.isRecurring {
                _lockChangeToRecurrance = State(initialValue: true)
            }
            
            // If the user selected the first future instance of a recurrence
            if transaction.isRecurring && instanceDate! > Date() && instanceDate == transaction.recurrenceDates.first {
                _defaultToEditAll = State(initialValue: true)
            }
            
            // If the transaction is archived or has a single instance
            if isArchiverd || !transaction.isRecurring {
                _defaultToEditAll = State(initialValue: true)
            }
        }
    }
    
    
    var body: some View {
        
        NavigationView {
            ScrollViewReader { proxy in
                
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
                                    if let systemName = selectedCategorySystemName,
                                       let category = getCategory(by: systemName) {
                                        Text(category.name)
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
                                    if category != "__nil_category__" {
                                        selectedCategorySystemName = category
                                    } else {
                                        selectedCategorySystemName = nil
                                    }
                                },
                                currentSelection: $selectedCategorySystemName
                            )
                        }
                    }
                    
                    Section(header: Text("Date"), footer: Text(isArchived ? "Recurrence is locked as this transaction occurs in the past. Please edit a future transaction to change recurrence." : "")) {
                        DatePicker(
                            "Transaction Date/Time",
                            selection: $transactionDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.graphical)
                        
                        HStack {
                            Text("\(Date(), format: .dateTime.hour().minute())")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Button("Change time to now") {
                                transactionDate = Date()
                            }
                        }
                        
                        Toggle("Recurring Transaction", isOn: $isRecurring)
                            .disabled(lockChangeToRecurrance)
                    }
                    
                    // Recurring Details
                    if isRecurring && !lockChangeToRecurrance {
                        Section(header: Text("Recurring Details")) {
                            Picker("Frequency", selection: $recurrenceFrequency) {
                                ForEach(RecurrenceFrequency.allCases) { freq in
                                    Text(freq.rawValue).tag(freq)
                                }
                            }
                            .pickerStyle(.segmented)
                            
                            Stepper("Every \(recurrenceInterval) \(getRecurrenceNoun())",
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
                                    .focused($focusedField, equals: .occurences)
                            }
                        }
                        .id("recurringSection")
                    }
                    
                    
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button(action: dismissKeyboard) {
                            Image(systemName: "keyboard.chevron.compact.down.fill")
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            onCancel()
                        }) {
                            Image(systemName: "xmark")
                                .foregroundStyle(Color.whiteInDarkBlackInLight)
                        }
                        .buttonBorderShape(.circle)
                        .buttonStyle(.bordered)
                    }
                }
                .onChange(of: isRecurring) { _, newValue in
                    if newValue {
                        withAnimation {
                            proxy.scrollTo("recurringSection", anchor: .bottom)
                        }
                    }
                }
                .navigationTitle(self.editMode ? "Edit Transaction" : "Add Transaction")
                .alert("Field cannot be empty", isPresented: $showErrorAlert) {
                    Button("OK", role: .cancel) {
                        showErrorAlert = false
                    }
                } message: {
                    Text("Please fill in all required fields.")
                }
                
                
                Button(action: {
                    
                    if editMode {
                        makeEditTypeDecision()
                    } else {
                        onSave()
                    }
                }) {
                    Text(self.editMode ? "Save" : "Add")
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .alert(
                "Apply Changes To..",
                isPresented: $showEditTypeDesicionDialog,
                presenting: editConfirmOptions
            ) { details in
                
                Button() {
                    editAllInstances(withOriginalDate: true)
                } label: {
                    Text("Yes, All")
                }
                
                Button() {
                    editInstancesMovingForwards(from: initialInstanceDate!)
                } label: {
                    Text("No, just from this one onwards")
                }
                
                Button(role: .cancel) {
                } label: {
                    Text("Cancel")
                }
                
            } message: { details in
                Text("There are some recurrences which happen before this one. Would you like those to be edited as well?")
            }
        }
    }
    
    
    private func dismissKeyboard() {
        focusedField = nil
    }
    
    
    private func getRecurrenceNoun() -> String {
        
        switch recurrenceFrequency {
            case .daily:
                return "Day"
            case .weekly:
                return "Week"
            case .monthly:
                return "Month"
            case .yearly:
                return "Year"
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
    
    
    private func makeEditTypeDecision() {
        
        if defaultToEditAll {
            editAllInstances(withOriginalDate: true)
            return
        }
        
        if transactionDate != initialInstanceDate {
            editInstancesMovingForwards(from: initialInstanceDate!)
            return
        }
        
        showEditTypeDesicionDialog = true
    }
    
    
    
    private func editAllInstances(withOriginalDate useOriginalDate: Bool = false) {
        
        if useOriginalDate {
            transactionDate = originalTransaction!.date
        }
        
        guard var amount = Double(transactionAmount) else {
            print("Invalid amount entered.")
            return
        }
        if (!isCredit) {
            amount *= -1
        }
    
        focusedField = nil
        
        
        var dateArray: [Date]
        
        // If the transaction was not recurring, but has been changed to be
        if !originalTransaction!.isRecurring && isRecurring {
            let start = transactionDate
            
            let limitDate = useEndDate ? endDate : nil
            let maxCount = useOccurrenceCount ? Int(occurrenceCount) : nil
            
            dateArray = computeRecurrenceDates(
                startDate: start,
                frequency: recurrenceFrequency,
                interval: recurrenceInterval,
                maxOccurrences: maxCount,
                endDate: limitDate
            )
            
            print("Transaction went from not recurring to recurring")
            
            
        } else if (
        // Else if the recurrance has been changed
            (useEndDate ||
             useOccurrenceCount ||
             recurrenceFrequency != originalTransaction!.recurrenceFrequency ||
             recurrenceInterval != originalTransaction!.recurrenceInterval ||
             transactionDate != originalTransaction!.date)
            && isRecurring
        ) {
            let start = transactionDate
            
            let limitDate = useEndDate ? endDate : nil
            let maxCount = useOccurrenceCount ? Int(occurrenceCount) : nil
            
            dateArray = computeRecurrenceDates(
                startDate: start,
                frequency: recurrenceFrequency,
                interval: recurrenceInterval,
                maxOccurrences: maxCount,
                endDate: limitDate
            )
            
            print("Transaction recurrence has been changed")
            
            
        } else {
        // Otherwise, just assign the current recurrance
            dateArray = originalTransaction!.recurrenceDates
            
            print("No change to recurrence")
        }
        
        if transactionTitle.isEmpty {
            print("Needs title")
            showErrorAlert = true
            return
        }
        
        if amount == 0 {
            print("Needs amount")
            showErrorAlert = true
            return
        }
        
        if AccountManager.shared.selectedAccount == nil {
            print("There is no account selected")
            showErrorAlert = true
            return
        }
        
        originalTransaction!.title = transactionTitle
        originalTransaction!.amount = amount
        originalTransaction!.isCredit = isCredit
        originalTransaction!.date = transactionDate
        originalTransaction!.note = transactionNote
        originalTransaction!.categorySystemName = selectedCategorySystemName!
        originalTransaction!.isRecurring = isRecurring
        originalTransaction!.recurrenceFrequency = isRecurring ? recurrenceFrequency : nil
        originalTransaction!.recurrenceInterval = recurrenceInterval
        originalTransaction!.recurrenceDates = dateArray
        
        try? context.save()
        
        FinancialEventManager.shared.doUpdates()
        
        dismiss()
    }
    
    
    
    private func editInstancesMovingForwards(from instanceDate: Date) {
        
        let unchangedDates: [Date] = originalTransaction!.recurrenceDates.filter { $0 < instanceDate}
        
        createNewTransaction(from: originalTransaction!, on: unchangedDates)
        
        remove(unchangedDates, from: originalTransaction!)
        
        editAllInstances()
    }
    
    
    private func createNewTransaction(from transaction: Transaction, on dates: [Date]) {
        
        let unchangedTransaction = Transaction(
            title: transaction.title,
            amount: transaction.amount,
            isCredit: transaction.isCredit,
            date: transaction.date,
            account: transaction.account,
            categorySystemName: transaction.categorySystemName,
            isRecurring: transaction.isRecurring,
            recurrenceDates: dates,
            isArchived: false
        )
        
        if transaction.isRecurring {
            unchangedTransaction.recurrenceFrequency = transaction.recurrenceFrequency
            unchangedTransaction.recurrenceInterval = transaction.recurrenceInterval
        }
        
        context.insert(unchangedTransaction)
        
        try? context.save()
    }
    
    private func remove(_ dates: [Date], from transaction: Transaction) {
        
        for date in dates {
            if let index = transaction.recurrenceDates.firstIndex(of: date) {
                transaction.recurrenceDates.remove(at: index)
            }
        }
        
        try? context.save()
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
            let start = transactionDate
            
            // End conditions
            let limitDate = useEndDate ? endDate : nil
            let maxCount = useOccurrenceCount ? Int(occurrenceCount) : nil
            
            dateArray = computeRecurrenceDates(
                startDate: start,
                frequency: recurrenceFrequency,
                interval: recurrenceInterval,
                maxOccurrences: maxCount,
                endDate: limitDate
            )
            
            
        } else {
            dateArray = [transactionDate]
        }
        
        if transactionTitle.isEmpty {
            print("Needs title")
            showErrorAlert = true
            return
        }
        
        if amount == 0 {
            print("Needs amount")
            showErrorAlert = true
            return
        }
        
        if selectedCategorySystemName == nil {
            selectedCategorySystemName = "circle.dashed"
        }
        
        if AccountManager.shared.selectedAccount == nil {
            print("There is no account selected")
            showErrorAlert = true
            return
        }
        
        
        let newTxn = Transaction(
            title: transactionTitle,
            amount: amount,
            isCredit: isCredit,
            date: transactionDate,
            account: AccountManager.shared.selectedAccount!,
            note: transactionNote,
            categorySystemName: selectedCategorySystemName!,
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
    ManageTransactionSheet()
        .modelContainer(for: Transaction.self)
}
