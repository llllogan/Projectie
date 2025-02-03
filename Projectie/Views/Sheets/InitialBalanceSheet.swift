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
                
                Text("Before you get started, enter the current balance of your savings accoint.\nWe will use this as your starting balance to get you going.")
                    .padding()
                    .multilineTextAlignment(.center)
                
                Form {
                    
                    Section {
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 40, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.leading)
                            .focused($focusedField, equals: .amount)
                    }
                }
                .scrollDisabled(true)
                .frame(height: 150)
                
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
        
        let newGoal = BalanceReset(date: Date(), balanceAtReset: amount, isStartingBalance: true)
        context.insert(newGoal)
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
