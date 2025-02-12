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
        
        // For our chart, we use the positive value for debits.
        let absoluteDebits = abs(totalDebits)
        
        // Determine the maximum value of the Y axis.
        let maxValue = max(totalCredits, absoluteDebits)
        let minValue = min(totalCredits, absoluteDebits)
        
        // Create default axis values using a stride.
        var defaultStep = maxValue / 5.0
        
        if let optimalStep = computeOptimalDivisor(maxValue: maxValue, s: minValue) {
            print("Found optimal step: \(optimalStep)")
            defaultStep = maxValue / optimalStep
        }
        
        var axisValues: [Double] = []
        if (minValue != 0 || maxValue != 0) {
            axisValues = Array(stride(from: 0, through: maxValue, by: defaultStep))
        }
        
        // Insert our custom marks if not already present.
        if !axisValues.contains(where: { abs($0 - totalCredits) < 0.001 }) {
            axisValues.append(totalCredits)
        }
        if !axisValues.contains(where: { abs($0 - absoluteDebits) < 0.001 }) {
            axisValues.append(absoluteDebits)
        }
        axisValues.sort()

        return Chart {
            BarMark(
                x: .value("Type", "Credits"),
                yStart: .value("Amount", 0),
                yEnd: .value("Amount", abs(totalDebits))
            )
            .foregroundStyle(Color.gray.opacity(0.2))
            BarMark(
                x: .value("Type", "Credits"),
                yStart: .value("Amount", 0),
                yEnd: .value("Amount", totalCredits)
            )
            .foregroundStyle(Color.carrotOrrangePale)
            
            BarMark(
                x: .value("Type", "Debits"),
                yStart: .value("Amount", 0),
                yEnd: .value("Amount", totalCredits)
            )
            .foregroundStyle(Color.gray.opacity(0.2))
            BarMark(
                x: .value("Type", "Debits"),
                yStart: .value("Amount", 0),
                yEnd: .value("Amount", abs(totalDebits))
            )
            .foregroundStyle(Color.carrotOrrangeDark)
        }
        .frame(height: 180)
        .chartYAxis {
            AxisMarks(position: .leading, values: axisValues) { value in
                // Check whether this mark matches one of our custom levels.
                if let doubleValue = value.as(Double.self) {
                    if abs(doubleValue - totalCredits) < 0.001 {
                        // Custom styling for total credits.
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            Text("\(totalCredits, format: .number.precision(.fractionLength(0)))").foregroundColor(Color.green)
                        }
                    } else if abs(doubleValue - absoluteDebits) < 0.001 {
                        // Custom styling for total debits.
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            Text("\(absoluteDebits, format: .number.precision(.fractionLength(0)))").foregroundColor(Color.red)
                        }
                    } else {
                        // Default axis mark styling.
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
            }
        }
        .padding()
    }
}

