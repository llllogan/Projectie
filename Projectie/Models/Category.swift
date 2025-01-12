//
//  Category.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 12/1/2025.
//

import SwiftData
import Foundation
import SwiftUI

@Model
final class Category {
    var title: String
    var systemName: String
    var createdAt: Date
    
    init(title: String, systemName: String, createdAt: Date = Date()) {
        self.title = title
        self.systemName = systemName
        self.createdAt = createdAt
    }
}


// MARK: - Preview
#Preview {
    // Provide a few sample Category objects for preview/demo
    let sampleCategories = [
        Category(title: "Category One", systemName: "star.fill"),
        Category(title: "Category Two", systemName: "heart.fill"),
        Category(title: "Category Three", systemName: "pencil")
    ]
    
    return CategoryPicker(categories: sampleCategories) { category in
        print("Selected category: \(category.title)")
    }
}
