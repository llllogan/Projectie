//
//  TransactionPresets.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 14/1/2025.
//

import Foundation
import SwiftUI

struct TransactionPreset: Identifiable {
    let id = UUID()
    let title: String
    let note: String
    let category: CategoryItem
    let isCredit: Bool
}

