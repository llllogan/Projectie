//
//  DeleteTransactionSheet.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 28/1/2025.
//

import SwiftUI

struct DeleteTransactionSheet: View {
    
    let onSelection: (TransactionDeleteChoice) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        NavigationView {
            VStack(alignment: .leading, spacing: 10) {
                Section {
                    Text("Delete all occurences of this transaction")
                        .font(.subheadline)
                    Button(action: {
                        onSelection(.all)
                    }) {
                        Text("Delete all")
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(Color.red)
                    .padding(.bottom)
                }
                Section {
                    Text("Delete only this occurence")
                        .font(.subheadline)
                    Button(action: {
                        onSelection(.thisOne)
                    }) {
                        Text("Delete this one")
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(Color.red)
                    .padding(.bottom)
                }
                Section {
                    Text("Delete this transaction, and all future occurences")
                        .font(.subheadline)
                    Button(action: {
                        onSelection(.future)
                    }) {
                        Text("Delete the future")
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(Color.red)
                    .padding(.bottom)
                }
            }
            .padding(.horizontal)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        
    }
}

#Preview {
    DeleteTransactionSheet { selectedOption in
        print(selectedOption)
    }
}
