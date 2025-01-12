//
//  CategoryPicker.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 12/1/2025.
//

import SwiftUI

struct CategoryPicker: View {
    /// The categories to display in the grid.
    let categories: [Category]
    
    /// A closure that returns the category the user tapped.
    let onCategorySelected: (Category) -> Void
    
    /// Define three flexible columns.
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(Array(categories.enumerated()), id: \.offset) { _, category in
                    Button {
                        onCategorySelected(category)
                    } label: {
                        VStack(spacing: 8) {
                            // Circle background with the systemName icon
                            ZStack {
                                Circle()
                                    .foregroundColor(.gray)
                                    .frame(width: 77, height: 77)
                                Image(systemName: category.systemName)
                                    .foregroundColor(.white)
                                    .imageScale(.large)
                            }
                            
                            // Category title
                            Text(category.title)
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
