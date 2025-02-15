//
//  ResetBalance.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 17/1/2025.
//

import SwiftUI
import Foundation

struct ResetBalanceSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var isPositive: Bool = true
    @State private var resetBalance: String = ""
    @State private var resetDate: Date = Date()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("AMOUNT")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                        .padding(.top, 7)
                        .padding(.leading, 30)
                        .padding(.bottom, 5)
                    HStack(spacing: 8) {
                        ZStack {
                            if isPositive {
                                Text("$")
                                    .font(.system(size: 40, weight: .medium, design: .rounded))
                                    // Choose a transition you like
                                    .transition(.identity)
                            } else {
                                Text("-$")
                                    .font(.system(size: 40, weight: .medium, design: .rounded))
                                    .transition(.identity)
                            }
                        }
                        // Tells SwiftUI to animate whenever isPositive changes
                        .animation(.easeInOut, value: isPositive)
                        
                        TextField("0.00", text: $resetBalance)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 40, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Button(action: {
                            withAnimation {
                                isPositive.toggle()
                            }
                        }) {
                            Image(systemName: "plusminus.circle.fill")
                                .rotationEffect(.init(degrees: isPositive ? 0 : 180))
                                .symbolEffect(.rotate)
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.circle)
                    
                    }
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    
                    
                    Text("AS OF")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                        .padding(.top)
                        .padding(.leading, 30)
                        .padding(.bottom, 5)
                    DatePicker(
                        "Transaction Date/Time",
                        selection: $resetDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                    .padding(5)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    
                    Text("Your current balance will be calculated from this reset amount and any future transactions.\nAll previous transactions will be uneffected, however their amounts will not have an effect going forwards")
                        .padding()
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: onCancel) {
                            Image(systemName: "xmark")
                                .foregroundStyle(Color.whiteInDarkBlackInLight)
                        }
                        .buttonBorderShape(.circle)
                        .buttonStyle(.bordered)
                    }
                }
                .navigationTitle("Correct Balance")
                
               
            }
        }
        
        Button(action: {
            onSave()
        }) {
            Text("Confirm Balance")
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
    
    private func onCancel() {
        dismiss()
    }

    private func onSave() {
        
        guard var amount = Double(resetBalance) else {
            print("Invalid amount entered.")
            return
        }
        if (!isPositive) {
            amount *= -1
        }
        
        if (AccountManager.shared.selectedAccount == nil) {
            print("No account selected")
            return
        }
        
        let newReset = BalanceReset(date: resetDate, balanceAtReset: amount, account: AccountManager.shared.selectedAccount!)
        context.insert(newReset)
        try? context.save()
        
        dismiss()
    }
}



#Preview {
    ResetBalanceSheet()
}
