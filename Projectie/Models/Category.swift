//
//  Category.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 14/1/2025.
//

import SwiftUI

struct CategoryItem: Identifiable {
    let id = UUID()
    let name: String
    let systemName: String
    let color: Color
}

let categories: [CategoryItem] = [
    CategoryItem(
        name: "Home",
        systemName: "house.fill",
        color: .blue.opacity(0.7)),
    CategoryItem(
        name: "Utilities",
        systemName: "lightbulb.fill",
        color: .blue.opacity(0.7)),
    CategoryItem(
        name: "Maintenance",
        systemName: "car.badge.gearshape",
        color: .blue.opacity(0.7)),
    
    
    CategoryItem(
        name: "Groceries",
        systemName: "cart.fill",
        color: .green.opacity(0.7)),
    
    CategoryItem(
        name: "Health",
        systemName: "heart.fill",
        color: .green.opacity(0.7)),
    CategoryItem(
        name: "Medical",
        systemName: "stethoscope",
        color: .green.opacity(0.7)),
    CategoryItem(
        name: "Self Care",
        systemName: "scissors",
        color: .green.opacity(0.7)),

    
    CategoryItem(
        name: "Personal",
        systemName: "person.fill",
        color: .orange.opacity(0.7)),
    CategoryItem(
        name: "Shopping",
        systemName: "gift.fill",
        color: .orange.opacity(0.7)),

    
    CategoryItem(
        name: "Transport",
        systemName: "bus",
        color: .brown.opacity(0.7)),
    
    
    CategoryItem(
        name: "Sport",
        systemName: "american.football.fill",
        color: .indigo.opacity(0.7)),
    CategoryItem(
        name: "Entertainment",
        systemName: "film.fill",
        color: .indigo.opacity(0.7)),
    
    
    CategoryItem(
        name: "Transfer",
        systemName: "tray.and.arrow.up.fill",
        color: .pink.opacity(0.7)),
    CategoryItem(
        name: "Income",
        systemName: "banknote.fill",
        color: .pink.opacity(0.7)),
    CategoryItem(
        name: "Savings",
        systemName: "dollarsign.bank.building.fill",
        color: .pink.opacity(0.7)),
    
    
    CategoryItem(
        name: "Default",
        systemName: "circle.dashed",
        color: .black.opacity(0.7))
]


#Preview {
    // Example usage: print the selected name in the debug console
    CategoryPicker { selectedName in
        print("Parent view received: \(selectedName)")
    }
}
