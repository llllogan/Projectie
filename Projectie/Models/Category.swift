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
        systemName: "wrench.and.screwdriver.fill",
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
        systemName: "bag.fill",
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
        systemName: "ticket.fill",
        color: .indigo.opacity(0.7)),
    
    
    CategoryItem(
        name: "Transfer",
        systemName: "arrow.left.arrow.right.square.fill",
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

func findCategoryBySystemName(_ systemName: String) -> CategoryItem {
    return categories.first(where: { $0.systemName == systemName }) ?? categories.first(where: { $0.systemName == "circle.dashed" })!
}


#Preview {
    CategoryPicker(
        onSystemNameSelected: { selectedName in
            print("Parent view received: \(selectedName)")
        }
    )
}
