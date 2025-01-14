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
            title: "Topup",
            note: "Topup from card.",
            category: findCategoryBySystemName("arrow.left.arrow.right.square.fill"),
            isCredit: true),
        TransactionPreset(
            title: "Transfer to card",
            note: "Remove money from account to use on card.",
            category: findCategoryBySystemName("arrow.left.arrow.right.square.fill"),
            isCredit: false),
        TransactionPreset(
            title: "Add savings",
            note: "Deposite savings into account.",
            category: findCategoryBySystemName("dollarsign.bank.building.fill"),
            isCredit: true)
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
