//
//  TransactionPresetTickers.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 15/1/2025.
//

import Foundation
import SwiftUI

struct TransactionPresetTickers: View {
    
    @State var transactionPresets: [TransactionPreset] = [
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
    
    var onPresetSelected: (TransactionPreset) -> Void = { _ in }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Presets")
                .font(.caption)
                .foregroundStyle(.secondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(transactionPresets) { preset in
                        PresetTicker(transactionPreset: preset, onSelect: onPresetSelected)
                    }
                }
            }
        }
    }
}

struct PresetTicker: View {
    
    var transactionPreset: TransactionPreset
    var onSelect: (TransactionPreset) -> Void
    
    var body: some View {
        Button(action: {
            onSelect(transactionPreset)
        }) {
            Text("\(transactionPreset.title)")
                .font(.subheadline)
        }
        .buttonBorderShape(.capsule)
        .buttonStyle(.bordered)
    }
}


#Preview {
    TransactionPresetTickers()
}
