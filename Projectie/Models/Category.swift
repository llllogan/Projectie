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
        name: "Sport",
        systemName: "american.football.fill",
        color: .indigo),
    CategoryItem(
        name: "Entertainment",
        systemName: "ticket.fill",
        color: .indigo),
    
    CategoryItem(
        name: "Transport",
        systemName: "bus",
        color: .brown),
    
    
    CategoryItem(
        name: "Home",
        systemName: "house.fill",
        color: .blue),
    CategoryItem(
        name: "Utilities",
        systemName: "lightbulb.fill",
        color: .blue),
    CategoryItem(
        name: "Maintenance",
        systemName: "wrench.and.screwdriver.fill",
        color: .blue),
    CategoryItem(
        name: "Bill",
        systemName: "text.document.fill",
        color: .blue),
    
    
    CategoryItem(
        name: "Income",
        systemName: "banknote.fill",
        color: Color(hue: 97/360, saturation: 0.9, brightness: 0.77)),
    CategoryItem(
        name: "Savings",
        systemName: "dollarsign.bank.building.fill",
        color: Color(hue: 97/360, saturation: 0.9, brightness: 0.77)),
    

    CategoryItem(
        name: "Transfer",
        systemName: "arrow.left.arrow.right.square.fill",
        color: .pink),
    CategoryItem(
        name: "Payment",
        systemName: "arrowshape.turn.up.right.fill",
        color: .pink),
    CategoryItem(
        name: "Cash",
        systemName: "banknote.fill",
        color: .pink),
    
    
    CategoryItem(
        name: "Personal",
        systemName: "person.fill",
        color: .orange),
    CategoryItem(
        name: "Shopping",
        systemName: "bag.fill",
        color: .orange),
    
    
    CategoryItem(
        name: "Groceries",
        systemName: "cart.fill",
        color: .green),
    
    CategoryItem(
        name: "Health",
        systemName: "heart.fill",
        color: .green),
    CategoryItem(
        name: "Medical",
        systemName: "stethoscope",
        color: .green),
    CategoryItem(
        name: "Self Care",
        systemName: "scissors",
        color: .green),

    
    CategoryItem(
        name: "None",
        systemName: "circle.dashed",
        color: .black),
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
