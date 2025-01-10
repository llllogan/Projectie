//
//  Item.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 10/1/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
