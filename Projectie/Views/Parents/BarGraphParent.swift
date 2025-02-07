//
//  BarGraphParent.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 7/2/2025.
//

import SwiftUI
import Charts
import SwiftData
import Foundation

struct BarGraphParent: View {
    
    @EnvironmentObject private var chartManager: ChartManager
    @EnvironmentObject private var financialEventManager: FinancialEventManager
    @EnvironmentObject private var timeManager: TimeManager
    
    @AppStorage("sqaureLines") private var squareLines: Bool = false
    
    
    var body: some View {
        
        let occurrences = financialEventManager.visibleEventOccurences
        
        let totalCredits = occurrences
            .map { $0.transaction?.amount ?? 0 }
            .filter { $0 > 0 }
            .reduce(0, +)
        
        let totalDebits = occurrences
            .map { $0.transaction?.amount ?? 0 }
            .filter { $0 < 0 }
            .reduce(0, +)

        return Chart {
            BarMark(
                x: .value("Type", "Credits"),
                y: .value("Amount", totalCredits)
            )
            .foregroundStyle(.green)
            
            BarMark(
                x: .value("Type", "Debits"),
                y: .value("Amount", abs(totalDebits))
            )
            .foregroundStyle(.red)
        }
        .frame(height: 180)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .padding()
    }
}

