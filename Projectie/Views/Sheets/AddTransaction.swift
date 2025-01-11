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
    
    var onSave: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Note", text: $transactionNote)
                    TextField("Amount (positive or negative)", text: $transactionAmount)
                        .keyboardType(.decimalPad)
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

