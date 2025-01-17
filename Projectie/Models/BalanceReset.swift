//
//  BalanceReset.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 17/1/2025.
//

import SwiftData
import Foundation

@Model
class BalanceReset {
    @Attribute(.unique) var id: UUID
    var date: Date
    var balanceAtReset: Double

    init(date: Date, balanceAtReset: Double) {
        self.id = UUID()
        self.date = date
        self.balanceAtReset = balanceAtReset
    }
}
