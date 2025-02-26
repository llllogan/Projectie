//
//  GoalListElement.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 20/1/2025.
//

import SwiftUI

struct BalanceResetListElement: View {
    
    @State var reset: BalanceReset
    @Environment(\.modelContext) private var context
    
    @State private var showConfirmDeleteAlert: Bool = false
    
    
    
    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            
            VStack(alignment: .leading, spacing: 2) {
                
                Text(reset.isStartingBalance ? "Starting Balance" : "Balance on \(reset.date, format: .dateTime.day().month(.wide).hour().minute())")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text("$\(reset.balanceAtReset, format: .number.precision(.fractionLength(2)))")
                    .font(.system(size: 20, weight: .medium, design: .rounded))

            }
            
            Spacer()
            
            
            Button(action: {
                showConfirmDeleteAlert = true
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
            .buttonBorderShape(.circle)
            .buttonStyle(.bordered)
            
        }
        .frame(maxWidth: .infinity)
        .alert("Confirm Delete", isPresented: $showConfirmDeleteAlert) {
            Button("Cancel", role: .cancel) {
                showConfirmDeleteAlert = false
            }
            Button("Delete", role: .destructive) {
                context.delete(reset)
                try? context.save()
            }
        } message: {
            Text("Are you sure you want to delete this balance?")
        }
    }
    
    
    
}

#Preview {
    
    let goals: [BalanceReset] = [
        BalanceReset(
            date: Date(),
            balanceAtReset: 1000,
            account: AccountManager.shared.selectedAccount!
        ),
        BalanceReset(
            date: Date(),
            balanceAtReset: 1000,
            account: AccountManager.shared.selectedAccount!,
            isStartingBalance: true
        )

    ]
    
    List(goals, id: \.self) { goal in
        BalanceResetListElement(reset: goal)
    }
}
