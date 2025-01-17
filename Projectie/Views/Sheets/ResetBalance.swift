//
//  ResetBalance.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 17/1/2025.
//

import SwiftUI
import Foundation

struct ResetBalanceSheet: View {
    
    @State private var isPositive: Bool = true
    @State private var resetBalance: String = ""
    @State private var resetDate: Date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Amount"), footer: Text("Flip the sign of the amount with the \(Image(systemName: "plusminus.circle")) button")) {
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
                }
                .animation(.easeInOut, value: isPositive)
                
                Section(header: Text("Date"), footer: Text("Your current balance will be calculated from this reset amount and any future transactions.\nAll previous transactions will be uneffected, however their amounts will not have an effect going forwards")) {
                    DatePicker(
                        "Transaction Date/Time",
                        selection: $resetDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Reset") {
                        onSave()
                    }
                }
            }
        }
        
    }
}

private func onCancel() {
    
}

private func onSave() {
    
}

#Preview {
    ResetBalanceSheet()
}
