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
    var account: Account
    var isStartingBalance: Bool

    init(date: Date, balanceAtReset: Double, account: Account, isStartingBalance: Bool = false) {
        self.id = UUID()
        self.date = date
        self.balanceAtReset = balanceAtReset
        self.account = account
        self.isStartingBalance = isStartingBalance
    }
}
