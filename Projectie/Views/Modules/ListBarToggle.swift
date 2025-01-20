//
//  ListBarToggle.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 20/1/2025.
//

import SwiftUI

struct ListBarToggle: View {
    
    @State private var selectedItem: Selection = .transactions
    
    
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 142, height: 45)
                .cornerRadius(25)
            
            Rectangle()
                .frame(width: 60, height: 35)
                .cornerRadius(17.5)
                .foregroundStyle(Color.black)
                .offset(x: selectionOffset)
            
            HStack {
                
                Button(action: {
                    withAnimation {
                        selectedItem = .transactions
                    }
                }) {
                    Image(systemName: "menucard")
                }
                .transition(.slide)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        selectedItem = .goals
                    }
                }) {
                    Image(systemName: "trophy")
                }
                .transition(.slide)
                
            }
            .frame(maxWidth: 90)
        }
        .frame(maxWidth: 100)
    }
    
    var selectionOffset: Double {
        switch selectedItem {
        case .transactions:
            return -35
        case .goals:
            return 35
        }
    }
}

#Preview {
    ListBarToggle()
}

enum Selection {
    case transactions
    case goals
}
