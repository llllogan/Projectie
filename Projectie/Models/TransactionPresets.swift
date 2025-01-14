//
//  TransactionPresets.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 14/1/2025.
//

import Foundation

struct TransactionPreset: Identifiable {
    let id = UUID()
    let title: String
    let note: String
    let category: CategoryItem
    let isCredit: Bool
}

let TransactionPresets: [TransactionPreset] = [
    TransactionPreset(
        title: "Transfer from card",
        note: "Topup from card.",
        category: (categories.first(where: { $0.systemName == "arrow.left.arrow.right.square.fill" }) ?? categories.first(where: { $0.systemName == "circle.dashed" }))!,
        isCredit: true),
    TransactionPreset(
        title: "Transfer to card",
        note: "Remove money from account to use on card.",
        category: (categories.first(where: { $0.systemName == "arrow.left.arrow.right.square.fill" }) ?? categories.first(where: { $0.systemName == "circle.dashed" }))!,
        isCredit: false),
]
