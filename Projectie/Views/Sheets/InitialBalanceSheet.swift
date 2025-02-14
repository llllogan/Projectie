//
//  InitialBalanceSheet.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 3/2/2025.
//

import SwiftUI

struct InitialBalanceSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    
    @Environment(\.modelContext) private var context
    
    @AppStorage("hasSetInitialBalance") private var hasSetInitialBalance: Bool = false
    
    @State private var amount: String = ""
    
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                
                Image(systemName: "trophy.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.yellow)
                    .hidden()
                Text("Welcome to Carrot!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Before you get started, enter the current balance of your savings account.\nThis will be your starting balance as of today.")
                    .padding()
                    .multilineTextAlignment(.center)
                
                TextField("0.00", text: $amount)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 40, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.leading)
                    .focused($focusedField, equals: .amount)
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.top, 20)
                
                Spacer()
                
                Button(action: {
                    saveBalance()
                }) {
                    Text("Save and Contine")
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                .buttonStyle(.bordered)
                .tint(Color(hue: 34/360, saturation: 0.99, brightness: 0.95))
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
        }
    }
    
    private func saveBalance() {
        guard let amount = Double(amount) else { return }
        
        guard let account = AccountManager.shared.selectedAccount else { return }
        
        let startingBalance = BalanceReset(date: Date(), balanceAtReset: amount, account: account, isStartingBalance: true)
        context.insert(startingBalance)
        try? context.save()
        
        hasSetInitialBalance = true
        
        dismiss()
    }
    
    enum Field {
        case amount
        case title
        case note
        case occurences
   }
}

#Preview {
    InitialBalanceSheet()
}
