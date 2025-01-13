//
//  CategoryPicker.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 12/1/2025.
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
        name: "Groceries",
        systemName: "cart.fill",
        color: .green.opacity(0.7)),
    CategoryItem(
        name: "Health",
        systemName: "heart.fill",
        color: .red.opacity(0.7)),
    CategoryItem(
        name: "Personal",
        systemName: "person.fill",
        color: .orange.opacity(0.7)),
    CategoryItem(
        name: "Maintenance",
        systemName: "car.badge.gearshape",
        color: .purple.opacity(0.7)),
    CategoryItem(
        name: "Transport",
        systemName: "bus",
        color: .brown.opacity(0.7)),
    CategoryItem(
        name: "Sport",
        systemName: "american.football.fill",
        color: .indigo.opacity(0.7)),
    CategoryItem(
        name: "Shopping",
        systemName: "gift.fill",
        color: .pink.opacity(0.7)),
    CategoryItem(
        name: "Utilities",
        systemName: "lightbulb.fill",
        color: .yellow.opacity(0.7)),
    CategoryItem(
        name: "Medical",
        systemName: "stethoscope",
        color: .mint.opacity(0.7)),
    CategoryItem(
        name: "Entertainment",
        systemName: "film.fill",
        color: .cyan.opacity(0.7)),
    CategoryItem(
        name: "Self Care",
        systemName: "scissors",
        color: .teal.opacity(0.7)),
    CategoryItem(
        name: "Transfer",
        systemName: "tray.and.arrow.up.fill",
        color: .pink.opacity(0.7)),
    CategoryItem(
        name: "Default",
        systemName: "circle.dashed",
        color: .black.opacity(0.7))
]


struct CategoryPicker: View {
    /// Hard-coded list of system icon names.
        
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    /// Closure that “returns” the tapped systemName string.
    /// The parent view can implement this closure to receive the selected systemName.
    var onSystemNameSelected: (String) -> Void = { _ in }

    // For automatically dismissing this view when an icon is tapped (optional).
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(categories) { category in
                    Button {
                        // Print for debugging
                        print("Selected systemName: \(category.systemName)")
                        // Send the systemName to whoever presented this view
                        onSystemNameSelected(category.systemName)
                        // Dismiss the sheet automatically (optional)
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        VStack(spacing: 8) {
                            // Circle background with the systemName icon
                            ZStack {
                                Circle()
                                    .foregroundColor(category.color)
                                    .frame(width: 77, height: 77)
                                Image(systemName: category.systemName)
                                    .foregroundColor(.white)
                                    .imageScale(.large)
                            }
                            Text(category.name)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }
}

#Preview {
    // Example usage: print the selected name in the debug console
    CategoryPicker { selectedName in
        print("Parent view received: \(selectedName)")
    }
}
