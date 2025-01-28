//
//  Goal.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 28/1/2025.
//

import SwiftData
import Foundation

@Model
final class Goal {
    var title: String
    var targetAmount: Double
    
    // Optionally track when this goal was first created
    var createdDate: Date
    
    init(title: String, targetAmount: Double, createdDate: Date = Date()) {
        self.title = title
        self.targetAmount = targetAmount
        self.createdDate = createdDate
    }
}
