//
//  ManageTransactionSheet.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 20/1/2025.
//

import SwiftUI
import SwiftData

struct DeleteAlertDetails: Identifiable {
    let id = UUID()
    let isArchived: Bool
}

struct TransactionSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var showDeleteOptions = false
    @State private var showEditTransactionAlert = false
    @State private var showDeleteConfirmation = false
    @State private var showEditSheet = false
    
    @State private var testFieldString: String = ""
    
    @FocusState private var focusedField: Field?
    
    @State private var deleteAlertDetails: DeleteAlertDetails = .init(isArchived: false)
    
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
                    .padding(.bottom, 20)
                    
                
                HStack(alignment: .top) {
                    
                    VStack (alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "clock")
                            Text("\(transaction.date, format: .dateTime.minute().hour())")
                        }
                        
                        HStack {
                            Image(systemName: "calendar")
                            Text("\(instanceDate, format: .dateTime.day().month().year())")
                        }

                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
                    
                    VStack (alignment: .leading, spacing: 8) {
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
                    .padding(.vertical, 5)

                }
                .padding(.vertical)
                .background(in: Rectangle())
                .backgroundStyle(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
                
                InfoModule(title: "Description", info: transaction.note ?? "-", subtitle: "")
                    .padding(.horizontal)
                
                
                HStack {
                    InfoModule(title: "Amount Per", info: String(transaction.pricePerWeek), isMoney: true, isCredit: transaction.isCredit, subtitle: "Week")
                    InfoModule(title: "Amount Per", info: String(transaction.pricePerDay), isMoney: true, isCredit: transaction.isCredit, subtitle: "Day")
                }
                .padding(.horizontal)

                                    

                Spacer()
                
                VStack(spacing: 10) {
                    Button(action: {
                        showEditSheet = true
                    }) {
                        Text("Edit")
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)
                    .buttonStyle(.bordered)
                    .tint(Color.primary)
                    
                    
                    
                    let isArchived = transaction.isArchived ?? false
                    let showDeletingOptions: Bool = transaction.isRecurring && !isArchived
                    
                    Group {
                        if showDeletingOptions {
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
                        } else {
                            Button(action: {
                                if (isArchived || transaction.date < Date()) {
                                    deleteAlertDetails = .init(isArchived: true)
                                } else {
                                    deleteAlertDetails = .init(isArchived: false)
                                }
                                showDeleteConfirmation = true
                            }) {
                                Text("Delete")
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal)
                            .buttonStyle(.borderedProminent)
                            .tint(Color.red)
                            .padding(.bottom)
                        }
                    }
                }
                
            }
            .padding(.top, 60)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(action: dismissKeyboard) {
                        Image(systemName: "keyboard.chevron.compact.down.fill")
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
            .sheet(isPresented: $showEditSheet) {
                ManageTransactionSheet(transaction: transaction)
            }
            .alert(
                "Confirm Delete",
                isPresented: $showDeleteConfirmation,
                presenting: deleteAlertDetails
            ) { details in
                
                Button(role: .destructive) {
                    deleteAllOccurrences()
                    dismiss()
                } label: {
                    Text("Delete")
                }
                
            } message: { details in
                Text(details.isArchived ? "Deleting this transaction may have an effect on your current balance.\nAre you sure?" : "Are you sure?")
            }
        }
    }
    
    
    private func dismissKeyboard() {
        focusedField = nil
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


struct InfoModule: View {
    
    var title: String
    var info: String
    var isMoney = false
    var isCredit = false
    var subtitle: String
    
    
    var body: some View {
        

        VStack {
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 15)
            .padding(.top, 10)
            
            Divider()
            
            HStack {
                if isMoney {
                    Text("\(isCredit ? "" : "-")$\(Double(info) ?? 0.0, format: .number.precision(.fractionLength(2)))")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .lineLimit(1)
                } else {
                    Text(info)
                        .font(.system(size: 15, weight: .regular, design: .default))
                }
                Spacer()
            }
            .padding(.horizontal, 15)
            
            HStack {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 15)
            
        }
        .padding(.vertical, 5)
        .padding(.bottom, 5)
        .background(in: Rectangle())
        .backgroundStyle(Color.gray.opacity(0.2))
        .cornerRadius(10)
            
        
    }
}


#Preview {
    TransactionSheet(
        transaction: Transaction(
            title: "Test",
            amount: 9.0,
            isCredit: true,
            date: Date(),
            account: Account(name: "Test", type: .saving),
            categorySystemName: "circle.dashed",
            isRecurring: true,
            recurrenceFrequency: .monthly,
            recurrenceInterval: 1
        ),
        instanceDate: Date()
    )
}
