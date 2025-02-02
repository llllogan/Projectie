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
    
    
    
    var body: some View {
        HStack(alignment: .bottom) {
            
            Button(action: {
                context.delete(reset)
                try? context.save()
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
            .buttonBorderShape(.circle)
            .buttonStyle(.bordered)
            
            Spacer()
            
            
            VStack(spacing: 8) {
                
                Image(systemName: reset.isStartingBalance ? "banknote" : "dollarsign.arrow.trianglehead.counterclockwise.rotate.90")
                    .font(.title3)
                
                
                Text(reset.isStartingBalance ? "Starting Balance" : "Balance Reset")
                    .font(.headline)
                
                Text("$\(reset.balanceAtReset, format: .number.precision(.fractionLength(2)))")
                    .font(.title)

                
            }
            
            Spacer()
            
            Button(action: { }) {
                Image(systemName: "pencil")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
            .buttonBorderShape(.circle)
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
    }
    
    
    
}

#Preview {
    
    let goals: [BalanceReset] = [
        BalanceReset(
            date: Date(),
            balanceAtReset: 1000
        ),
        BalanceReset(
            date: Date(),
            balanceAtReset: 1000,
            isStartingBalance: true
        )

    ]
    
    List(goals, id: \.self) { goal in
        BalanceResetListElement(reset: goal)
    }
}
