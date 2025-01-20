//
//  GoalListElement.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 20/1/2025.
//

import SwiftUI

struct ResetListElement: View {
    
    @State var balance: Double
    
    
    var body: some View {
        VStack(spacing: 8) {
            
            Image(systemName: "dollarsign.arrow.trianglehead.counterclockwise.rotate.90")
                .font(.title3)
            Text("Balance Reset")
                .font(.headline)
            
            Text("$\(balance, format: .number.precision(.fractionLength(2)))")
                .font(.title)

            
        }
        .frame(maxWidth: .infinity)
    }
    
    
    
}

#Preview {
    
    let goals: [Double] = [100, 200, 300, 400, 500]
    
    List(goals, id: \.self) { goal in
        ResetListElement(balance: goal)
    }
}
