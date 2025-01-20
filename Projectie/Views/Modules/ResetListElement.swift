//
//  GoalListElement.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 20/1/2025.
//

import SwiftUI

struct BalanceResetListElement: View {
    
    @State var reset: BalanceReset
    
    
    var body: some View {
        VStack(spacing: 8) {
            
            Image(systemName: reset.isStartingBalance ? "banknote" : "dollarsign.arrow.trianglehead.counterclockwise.rotate.90")
                .font(.title3)
            
            
            Text(reset.isStartingBalance ? "Starting Balance" : "Balance Reset")
                .font(.headline)
            
            Text("$\(reset.balanceAtReset, format: .number.precision(.fractionLength(2)))")
                .font(.title)

            
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
